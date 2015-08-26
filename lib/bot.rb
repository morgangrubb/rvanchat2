# Starts when the script exits.
#
# Run with bundle exec rails runner lib/bot.rb
#

require 'jabbot'
require 'uri'

require './lib/bot/monkey_patch'
require './lib/bot/bot'
require './lib/bot/message'
require './lib/bot/handler'

configure do |conf|
  conf.nick = "@wopr#{Rails.env.development? ? '-dev' : ''}"
  conf.login = "bot@#{XMPP_HOST}"
  conf.channel = MAIN_ROOM
  conf.server = CONFERENCE_HOST
  conf.password = "thisisthebotpassword"
  # conf.log_level = 'info'
  # conf.log_file = "/home/ubuntu/rvanchat/current/log/bot.log"
  conf.debug = true
end

# Redis
redis_client = Rvanchat.redis(:new, db: 1)

# Currently there is no mechanism for determining the room in the message.
current_room = Room.where(name: MAIN_ROOM).first

# We use this controller to enable modules.
controller = Bot::HandlerController.new(redis: redis_client, room: current_room)

# Register all the handlers we have, in the order in which they're going to
# process requests. Most specific first.
[
  Bot::Handler::Control,
  Bot::Handler::Record,
  Bot::Handler::Help,
  Bot::Handler::Google,
  Bot::Handler::Facebook,
  Bot::Handler::Twitter,
  Bot::Handler::Imgur,
  Bot::Handler::Giphy,
  Bot::Handler::Seen,
  Bot::Handler::Link,
  Bot::Handler::Eliza
].each do |handler|
  controller.register handler
end

def feed_action_to_controller(event, message, params)
  controller.receive event, Bot::Message.new(message), params
end

join do |message, params|
  feed_action_to_controller :join_room, message, params
end

leave do |message, params|
  feed_action_to_controller :leave_room, message, params
end

message do |message, params|
  feed_action_to_controller :public_message, message, params
end

query do |message, params|
  feed_action_to_controller :private_message, message, params
end

subject do |message, params|
  feed_action_to_controller :subject_change, message, params
end
