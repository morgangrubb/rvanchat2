module Bot
  module Handler
    class Help < Bot::Handler::Base
      def public_message(message, params)
        if message.text =~ /^!help$/
          say_help(message.user_name)
        end
      end

      def private_message(message, params)
        if message.text =~ /^!help$/
          say_help(message.user_name)
        end
      end

      def enabled?
        true
      end

      private

      def say_help(user_name)
        say "This is where the help message goes", user_name: user_name
      end
    end
  end
end
