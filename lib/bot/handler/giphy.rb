module Bot
  module Handler
    class Giphy < Bot::Handler::Base

      def public_message(message, params)
        if message.text =~ /^!giphy$/
          message.processed!
          say_help message.user_name
          say_image Giphy.random
        elsif message.text =~ /^!giphy (.+)$/
          message.processed!
          say_image Giphy.search($1, limit: 50).sample
        end
      end

      def describe_commands(message)
        "Find a random gif with\n!giphy\nor search for a specific gif with\n!giphy <search term>"
      end

      private

      def say_help(user_name)
        examples = [
          "all the things",
          "KAHN",
          "stupid robot",
          "very good puppy dog",
          "omfg"
        ]
        say "The command is:\n!giphy searchterm\nFor example:\n!giphy #{examples.sample}", user_name: user_name
      end

      def say_image(giphy, include_url: false)
        if include_url
          say "#{giphy.fixed_height_downsampled_url}\n#{giphy.url}"
        else
          say "#{giphy.fixed_height_downsampled_url}"
        end
      end

    end
  end
end
