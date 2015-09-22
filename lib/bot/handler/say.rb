module Bot
  module Handler
    class Say < Bot::Handler::Base

      def private_message(message, params)
        if message.from_admin?
          case message.text
          when /^!say (.*)$/
            message.processed!
            say $1, record: true
          end
        end
      end

    end
  end
end
