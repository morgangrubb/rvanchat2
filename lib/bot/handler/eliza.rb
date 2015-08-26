module Bot
  module Handler
    class Eliza < Bot::Handler::Base

      def private_message(message, params)
        return if message.processed?
        return if message.command?

        # TODO: Run Eliza.
      end

    end
  end
end
