# Starts when the script exits.
#
# Run with bundle exec rails runner lib/bot.rb
#

require 'jabbot'
require 'uri'

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
  post "Hi, #{message.user}. Welcome to rvanchat."
end

leave do |message, params|
  post "and there he goes...good bye, #{message.user}"
end

# Link reaper
message do |message, params|
  user_id = User.where(xmpp_username: message.user).first.try(:id)
  stored_message =
    Message.create(
      user_name: message.user,
      room_name: ACTUAL_ROOM.name,
      user_id: user_id,
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
