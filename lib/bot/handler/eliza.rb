require "eliza"
require 'eliza/key'
require 'eliza/memory'
require 'eliza/script'
require 'eliza/interpreter'

module Bot
  module Handler
    class Eliza < Bot::Handler::Base

      def initialize(*args)
        super(*args)
        @chats = {}
      end

      def private_message(message, params)
        return if message.processed?
        return if message.command?

        chat = chat_for(message.user_name)
        reply = chat.process_input message.text
        say reply, user_name: message.user_name
        end_chat_for message.user_name if chat.done
      end

      def leave_room(message, params)
        end_chat_for(message.user_name)
      end

      private

      def chat_for(user_name)
        @chats[user_name] ||= ::Eliza::Interpreter.new('/scripts/original.txt')
      end

      def end_chat_for(user_name)
        @chats.delete user_name
      end

    end
  end
end
