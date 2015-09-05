module Bot
  module Handler
    class Giphy < Bot::Handler::Base

      def public_message(message, params)
        if message.text =~ /^!giphy$/
          message.processed!
          say_image Giphy.random
        elsif message.text =~ /^!giphy (.+)$/
          message.processed!
          say_image Giphy.search($1, limit: 50).sample
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

      def say_image(giphy, include_url: false)
        if include_url
          say "#{giphy.image_url.to_s}\n#{giphy.url.to_s}"
        else
          say "#{giphy.image_url.to_s}"
        end
      end

    end
  end
end
