module Bot
  module Handler
    class Coin < Bot::Handler::Base

      def private_message(message, params)
        case message.text
        when /^!(coin|cointoss|coinflip|flipcoin|flip)(\s+.*)?$/
          message.processed!
          say "You get #{flip_coin}.", user_name: message.user_name
        when /^!(tails|heads)(\s+.*)?$/
          message.processed!
          toss = flip_coin
          if toss == $1
            say "#{toss.capitalize}, you win.", user_name: message.user_name
          else
            say "#{toss.capitalize}, you lose.", user_name: message.user_name
          end
        end
      end

      def public_message(message, params)
        case message.text
        when /^!(coin|cointoss|coinflip|flipcoin|flip)(\s+.*)?$/
          message.processed!
          say "#{message.user_name} gets #{flip_coin}."
        when /^!(tails|heads)(\s+.*)?$/
          message.processed!
          toss = flip_coin
          if toss == $1
            say "#{toss.capitalize}, #{message.user_name} wins."
          else
            say "#{toss.capitalize}, #{message.user_name} loses."
          end
        end
      end

      def describe_commands(message)
        [
          "Flip a coin with:",
          "!coin, !cointoss, !coinflip, !flipcoin, !flip",
          "!heads",
          "!tails"
        ].join("\n")
      end

      def flip_coin
        ["heads", "tails"].sample
      end

    end
  end
end
