require 'rest-client'
require 'builder'
require 'rexml/document'
require 'base64'
require 'hpricot'
require 'timeout'

class Bosh
  BOSH_XMLNS    = 'http://jabber.org/protocol/httpbind'
  TLS_XMLNS     = 'urn:ietf:params:xml:ns:xmpp-tls'
  SASL_XMLNS    = 'urn:ietf:params:xml:ns:xmpp-sasl'
  BIND_XMLNS    = 'urn:ietf:params:xml:ns:xmpp-bind'
  SESSION_XMLNS = 'urn:ietf:params:xml:ns:xmpp-session'
  CLIENT_XMLNS  = 'jabber:client'

  class Error < StandardError; end
  class TimeoutError < Bosh::Error; end
  class AuthFailed < Bosh::Error; end
  class ConnFailed < Bosh::Error; end

  @@logging = true
  @@fast_mode = false
  def self.logging=(value)
    @@logging = value
  end
  def self.fast_mode=(value)
    @@fast_mode = value
  end

  attr_accessor :jid, :rid, :sid, :success
  def initialize(jid, pw, service_url, opts={})
    @service_url = service_url
    @jid, @pw = jid, pw
    @host = jid.split("@").last
    @success = false
    @timeout = opts[:timeout] || 3 #seconds
    @headers = {"Content-Type" => "text/xml; charset=utf-8",
                "Accept" => "text/xml"}
    @wait    = opts[:wait]   || 5
    @hold    = opts[:hold]   || 3
    @window  = opts[:window] || 5
  end

  def success?
    @success == true
  end

  def self.initialize_session(*args)
    new(*args).connect
  end

  def connect
    initialize_bosh_session
    if send_auth_request
      @success = send_restart_request
      unless @@fast_mode
        request_resource_binding
        @success = send_session_request
      end
    end

    raise Bosh::AuthFailed, "could not authenticate #{@jid}" unless success?
    @rid += 1 #updates the rid for the next call from the browser

    {
      jid: @jid,
      sid: @sid,
      rid: @rid
    }
  end

  def deliver(xml)
    timeout(@timeout) do
      send(xml)
      recv(RestClient.post(@service_url, xml, @headers))
    end
  rescue ::Timeout::Error => e
    raise Bosh::TimeoutError, e.message
  rescue Errno::ECONNREFUSED => e
    raise Bosh::ConnFailed, "could not connect to #{@host}\n#{e.message}"
  rescue Exception => e
    raise Bosh::Error, e.message
  end

  private
  def initialize_bosh_session
    response = deliver(construct_body(:wait => @wait, :to => @host,
                                      :hold => @hold, :window => @window,
                                      "xmpp:version" => '1.0'))
    parse(response)
  end

  def construct_body(params={}, &block)
    @rid ? @rid+=1 : @rid=rand(100000)

    builder = Builder::XmlMarkup.new
    parameters = {:rid => @rid, :xmlns => BOSH_XMLNS,
                  "xmpp:version" => "1.0",
                  "xmlns:xmpp" => "urn:xmpp:xbosh"}.merge(params)

    if block_given?
      builder.body(parameters) {|body| yield(body)}
    else
      builder.body(parameters)
    end
  end

  def send_auth_request
    request = construct_body(:sid => @sid) do |body|
      auth_string = "#{@jid}\x00#{@jid.split("@").first.strip}\x00#{@pw}"
      body.auth(Base64.encode64(auth_string).gsub(/\s/,''),
                    :xmlns => SASL_XMLNS, :mechanism => 'PLAIN')
    end

    response = deliver(request)
    response.include?("success")
  end

  def send_restart_request
    request = construct_body(:sid => @sid, "xmpp:restart" => true, "xmlns:xmpp" => 'urn:xmpp:xbosh')
    deliver(request).include?("stream:features")
  end

  def request_resource_binding
    request = construct_body(:sid => @sid) do |body|
      body.iq(:id => "bind_#{rand(100000)}", :type => "set",
              :xmlns => "jabber:client") do |iq|
        iq.bind(:xmlns => BIND_XMLNS) do |bind|
          bind.resource("bosh_#{rand(10000)}")
        end
      end
    end

    response = deliver(request)
    response.include?("<jid>")
  end

  def send_session_request
    request = construct_body(:sid => @sid) do |body|
      body.iq(:xmlns => CLIENT_XMLNS, :type => "set",
              :id => "sess_#{rand(100000)}") do |iq|
        iq.session(:xmlns => SESSION_XMLNS)
      end
    end

    response = deliver(request)
    response.include?("body")
  end

  def parse(_response)
    doc = Hpricot(_response.to_s)
    doc.search("//body").each do |body|
      @sid = body.attributes["sid"].to_s
    end
    _response
  end

  def timeout(secs, &block)
    if defined?(SystemTimer)
      SystemTimer.timeout(secs) do
        block.call
      end
    else
      warn "WARNING: using the built-in Timeout class which is known to have issues when used for opening connections. Install the SystemTimer gem if you want to make sure the Redis client will not hang." unless RUBY_VERSION >= "1.9" || RUBY_PLATFORM =~ /java/
      ::Timeout::timeout(secs) do
        block.call
      end
    end
  end

  def send(msg)
    puts("Ruby-BOSH - SEND\n[#{now}]: #{msg}") if @@logging; msg
  end

  def recv(msg)
    puts("Ruby-BOSH - RECV\n[#{now}]: #{msg}") if @@logging; msg
  end

  def now
    Time.now.strftime("%a %b %d %H:%M:%S %Y")
  end
end


if __FILE__ == $0
  p Bosh.initialize_session(ARGV[0], ARGV[1],
      "http://localhost:5280/http-bind")
end
