# Starts when the script exits.
#
# Run with bundle exec rails runner lib/bot.rb
#

require 'jabbot'
require 'uri'

# Where we're stuffing logs and things.
redis = Rvanchat.redis :new, db: 1

BLOCKED_HOSTS = %w[ localhost 127.0.0.1 ]

DEFAULT_ENCODINGS = %w[ utf8 utf-8 UTF8 UTF-8 ]

def log(com, msg)
  $stderr.puts "#{msg.time} | #{com} | <#{msg.user}> #{msg.text}"
end

TITLE_MAX_LENGTH = 100

TWITTER_BASE   = "http://twitter.com/statuses/show/"
TWITTER_FORMAT = "json"

TWITTER_REGEX  = /https?:\/\/twitter.com\/[^\/]+\/status\/(\d+)/
TWITTER_FAIL   = "Twitter failure. :("

def get_user_from(message)
  User.where(xmpp_username: message.user).first
end

def last_seen(user)
  redis.hset "last_seen", user.id, Time.now.to_i
end

def twitter(params)
  twitter_id = nil
  params[:id].gsub!(/\s/, '')
  if params[:id] =~ TWITTER_REGEX
    twitter_id = $1
  elsif !(params[:id] =~ /\A\d+\z/)
    return "Couldn't find a twitter id."
  else
    twitter_id = params[:id]
  end

  if twitter_id
    begin
      resp = open("#{TWITTER_BASE}#{twitter_id}.#{TWITTER_FORMAT}").read
      json = JSON.parse(resp)
      time = Time.parse(json["created_at"]).strftime("%d.%m.%Y %H:%M")
      user = json["user"]["screen_name"]
      mess = json["text"]

      "[#{time}] #{user}: #{mess}"
    rescue OpenURI::HTTPError => e
      "Not a link? Twitter failure? Pete only knows."
    end
  end
end

configure do |conf|
  conf.nick = "@wopr"
  conf.login = "bot@#{XMPP_HOST}"
  conf.channel = MAIN_ROOM
  conf.server = CONFERENCE_HOST
  conf.password = "thisisthebotpassword"
  conf.log_level = 'info'
  conf.log_file = "/home/ubuntu/rvanchat/current/log/bot.log"
  conf.debug = true
end

ACTUAL_ROOM = Room.where(name: MAIN_ROOM).first

# Welcome everybody
join do |message, params|
  user = get_user_from(message)

  if user
    last_seen(user)
    if !redis.sismember("welcomed", user.id)
      redis.sadd("welcomed", user.id)
      post "Hi, #{message.user}. Welcome to rvanchat."
    elsif !redis.exists("welcome_back:#{user.id}")
      redis.setex("welcome_back:#{user.id}", 3.days, true)
      post "Hi, #{message.user}. Welcome back."
    end
  end
end

# Link reaper
message do |message, params|
  user = get_user_from(message)
  last_seen(user) if user

  stored_message =
    Message.create(
      user_name: message.user,
      room_name: ACTUAL_ROOM.name,
      user_id: user.try(:id),
      room_id: ACTUAL_ROOM.id,
      text: message.text
    )

  links = URI.extract(message.text)

  links.each do |url|
    uri = URI.parse(url)
    Link.create(
      message_id: stored_message.id,
      host: uri.host,
      url: uri.to_s
    )
  end

  links.each do |url|
    begin
      next if message.text =~ /\A\s*!\w+/

      uri = URI.parse(params[0])
      if !BLOCKED_HOSTS.include?(uri.host)
        case uri.to_s
        when TWITTER_REGEX
          $stderr.puts "it's a twitter url! fetch it!"
          msg = twitter({:id => uri.to_s})
          post msg ? msg : TWITTER_FAIL
        else
          req = fetch(uri) # handle redirects
          doc = Nokogiri::HTML(req.body)
          if req.header['content-type'] =~ /text/i
            http_equiv = doc.css("meta[http-equiv=content-type]").first
            if http_equiv && content = http_equiv.attributes['content']
              send_encoding = content.to_s.gsub(/^.+charset=/, '')
            end

            if !send_encoding && req.header['content-type'] =~ /^.+charset=(.+)/i
              send_encoding = $1
            end

            if doc && title = doc.css("title")
              if !title.empty?
                title = title[0].content.gsub(/\r/, '').gsub(/\n/, ' ').gsub(/\s+/, ' ')
                if title.length > TITLE_MAX_LENGTH
                  title = title[0, TITLE_MAX_LENGTH] + '...'
                end

                if send_encoding && !DEFAULT_ENCODINGS.include?(send_encoding)
                  title = Iconv.iconv(DEFAULT_ENCODINGS.first, send_encoding, title)[0]
                end

                post "Title: #{title} (at #{uri.host} )"
              else
                post "Title: <empty> (at #{uri.host} )"
              end
            end
          end
        end
      end

    rescue SocketError => e
      if e.message == "getaddrinfo: No address associated with hostname"
        post "Die angegebene Seite existiert nicht."
      else
        $stderr.puts "We're on line #{__LINE__}"
        $stderr.puts e.inspect
        $stderr.puts uri.inspect
        $stderr.puts message.inspect
      end
    rescue Exception => e
      $stderr.puts "We're on line #{__LINE__}"
      $stderr.puts e.inspect
      $stderr.puts uri.inspect
      $stderr.puts message.inspect
    end
    # Does it look like Twitter, Facebook or Youtube?
  end
end

message /^hi,? @?wopr/i do |message, params|
  post "Hi, #{message.user}"
  post "Use !help for a list of commands" => message.user
end

message "!help" do |message, params|
  response = <<-EOS
I understand these commands:
  !help

These commands will eventually work:
  !giphy
  !google
  !youtube
  !meme
  !stats

I will also eventually capture and parse Twitter, Facebook and Youtube links, too.

For the time being I'm a bit stupid.
  EOS
  post response => message.user
end

# TODO: Giphy api
# TODO: Youtube fetcher
# TODO: Stats counter
