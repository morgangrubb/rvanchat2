module Bot
  module Handler
    class Help < Bot::Handler::Base
      def public_message(message, params)
        if message.text =~ /^!help$/
          say_help(message)
        end
      end

      def private_message(message, params)
        if message.text =~ /^!help$/
          say_help(message)
        end
      end

      def enabled?
        true
      end

      private

      def say_help(message)
        commands = []

        controller.enabled_handlers.each do |handler_name|
          handler = controller.handlers[handler_name]
          commands << handler.describe_commands(message)
        end

        commands.compact!

        if commands.empty?
          say "No commands you can use at the moment, sorry.", user_name: message.user_name
        else
          say "Available commands:\n\n#{commands.join("\n\n")}", user_name: message.user_name
        end
      end
    end
  end
end
