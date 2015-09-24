module Bot
  module Handler
    class Coin < Bot::Handler::Base

      def private_message(message, params)
        case message.text
        when /^!coin(\s+.*)?$/
          message.processed!
          say "You get #{flip_coin}.", user_name: message.user_name
        end
      end

      def public_message(message, params)
        case message.text
        when /^!coin(\s+.*)?$/
          message.processed!
          say "#{message.user_name} gets #{flip_coin}."
        end
      end

      def describe_commands(message)
        [
          "Flip a coin with:",
          "!coin"
        ].join("\n")
      end

      def flip_coin
        ["heads", "tails"].sample
      end

    end
  end
end
