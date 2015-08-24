# Starts when the script exits.
#
# Run with bundle exec rails runner lib/bot.rb
#

require 'jabbot'
require 'uri'

configure do |conf|
  conf.nick = "bot"
  conf.login = "bot@#{XMPP_HOST}"
  conf.channel = MAIN_ROOM
  conf.server = CONFERENCE_HOST
  conf.password = "thisisthebotpassword"
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
      user_name: message.user.encode("UTF-8"),
      room_name: ACTUAL_ROOM.name,
      user_id: user_id,
      room_id: ACTUAL_ROOM.id,
      text: CGI::escape(message.text)
    )

  URI.extract(message.text).each do |url|
    uri = URI.parse(url)
    Link.create(
      message_id: stored_message.id,
      host: uri.host,
      url: uri.to_s
    )
  end
end

# TODO: Giphy api
# TODO: Youtube fetcher
# TODO: Stats counter
