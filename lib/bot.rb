# Starts when the script exits.
#
# Run with bundle exec rails runner lib/bot.rb
#

require 'jabbot'
require 'uri'

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
controller = Bot::Handler::Control.new(redis: redis_client, room: current_room)

# Bots run in this order.
#
# Multiple handlers can run on a single message. They need to flag the message
# as handled if they've dealt to it.
handler_options = {
  redis: redis_client,
  room: current_room,
  controller: controller
}

HANDLERS = [
  controller,
  Bot::Handler::Record.new(handler_options),
  Bot::Handler::Help.new(handler_options),
  Bot::Handler::Google.new(handler_options),
  Bot::Handler::Facebook.new(handler_options),
  Bot::Handler::Twitter.new(handler_options),
  Bot::Handler::Imgur.new(handler_options),
  Bot::Handler::Giphy.new(handler_options),
  Bot::Handler::Seen.new(handler_options),
  Bot::Handler::Link.new(handler_options)
]

def feed_action_to_handlers(action, message, params)
  bot_message = Bot::Message.new(message)

  HANDLERS.each do |handler|
    handler.process(action, bot_message, params)
  end
end

join do |message, params|
  feed_action_to_handlers :join_room, message, params
end

leave do |message, params|
  feed_action_to_handlers :leave_room, message, params
end

message do |message, params|
  feed_action_to_handlers :public_message, message, params
end

query do |message, params|
  feed_action_to_handlers :private_message, message, params
end
