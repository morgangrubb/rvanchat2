# Starts when the script exits.
#
# Run with bundle exec rails runner lib/bot.rb
#

require 'jabbot'
require 'uri'

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

require './lib/bot/bot'
require './lib/bot/monkey_patch'
require './lib/bot/handler_controller'
require './lib/bot/handler'
require './lib/bot/message'

# We use this controller to enable modules.
def handler_controller
  return @handler_controller if defined? @handler_controller

  redis_client = Rvanchat.redis(:new, db: 1)
  current_room = Room.where(name: MAIN_ROOM).first
  @handler_controller = Bot::HandlerController.new(redis: redis_client, room: current_room)
end

# Register all the handlers we have, in the order in which they're going to
# process requests. Most specific first.
[
  Bot::Handler::Admin,
  Bot::Handler::Whois,
  Bot::Handler::Say,
  Bot::Handler::Control,
  Bot::Handler::Background,
  Bot::Handler::Record,
  Bot::Handler::Help,
  Bot::Handler::Google,
  Bot::Handler::Facebook,
  Bot::Handler::Twitter,
  Bot::Handler::Youtube,
  Bot::Handler::Imgur,
  Bot::Handler::Giphy,
  Bot::Handler::EightBall,
  Bot::Handler::Roll,
  Bot::Handler::Seen,
  Bot::Handler::Link,
  Bot::Handler::Eliza
].each do |handler|
  handler_controller.register handler
end

join do |message, params|
  handler_controller.receive :join_room, Bot::Message.new(message), params
end

leave do |message, params|
  handler_controller.receive :leave_room, Bot::Message.new(message), params
end

message do |message, params|
  handler_controller.receive :public_message, Bot::Message.new(message), params
end

private_message do |message, params|
  handler_controller.receive :private_message, Bot::Message.new(message), params
end

subject do |message, params|
  handler_controller.receive :subject_change, Bot::Message.new(message), params
end

# Dirty horrible hack to remove the annoying kernel method that breaks Faraday.
#
# TODO: Remove the other methods?
module Jabbot::Macros
  alias :jabbot_query :query
  remove_method :query
end
