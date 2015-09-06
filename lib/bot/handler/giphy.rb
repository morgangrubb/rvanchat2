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
        # Insert this image into the link log with the command that was issued.
        stored_message =
          ::Message.create(
            user_name: "@wopr",
            user_id: nil,
            room_name: @options[:room].name,
            room_id: @options[:room].id,
            text: "#{message.user_name}: #{message.text}\n=> #{giphy.image_url.to_s}"
          )

        # Stash the link
        uri = URI.parse(giphy.image_url.to_s)

        ::Link.create(
          message_id: stored_message.id,
          host: uri.host,
          url: giphy.image_url.to_s
        )

        if false
          say "#{giphy.image_url.to_s}\n#{giphy.url.to_s}"
        else
          say giphy.image_url.to_s
        end
      end

    end
  end
end
