module Bot
  module Handler
    class Record < Bot::Handler::Base
      def public_message(message, params)
        return if message.command?

        # Stash this message in the database
        stored_message =
          ::Message.create(
            user_name: message.user_name,
            user_id: message.user.try(:id),
            room_name: @options[:room].name,
            room_id: @options[:room].id,
            text: message.text
          )

        # Stash the links
        message.links.each do |link|
          ::Link.create(
            message_id: stored_message.id,
            host: link.parsed.host,
            url: link.parsed.to_s
          )
        end
      end
    end
  end
end
