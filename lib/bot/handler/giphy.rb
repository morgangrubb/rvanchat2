module Bot
  module Handler
    class Giphy < Bot::Handler::Base

      def public_message(message, params)
        if message.text =~ /^!giphy$/
          message.processed!
          say_image ::Giphy.random, message
        elsif message.text =~ /^!giphy (.+)$/
          message.processed!
          say_image ::Giphy.random($1), message
        end
      end

      def describe_commands(message)
        examples = [
          "all the things",
          "KAHN",
          "stupid robot",
          "very good puppy dog",
          "omfg"
        ]

        "Find a random gif with\n!giphy\nor search for a specific gif with\n!giphy #{examples.sample}"
      end

      private

      def say_image(giphy, message)
        text = "#{message.user_name}: #{message.text}\n=> #{giphy.image_url.to_s}"

        if false
          say "#{giphy.image_url.to_s}\n#{giphy.url.to_s}", record: text
        else
          say giphy.image_url.to_s, record: text
        end
      end

    end
  end
end
