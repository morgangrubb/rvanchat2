require 'base64'
require 'xmpp4r/vcard'
require 'xmpp4r/vcard/helper/vcard'

class JabberService
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def client
    @client ||=
      begin
        client = Jabber::Client.new(user.jid)
        client.connect("localhost", 5222)
        client.auth(user.xmpp_password)
        client
      end
  end

  def vcard_helper
    @vcard_helper ||= Jabber::Vcard::Helper.new(client)
  end

  def perform(&block)
    begin
      yield &block
    ensure
      client.close
      @client = nil
      @vcard_helper = nil
    end
  end
end
