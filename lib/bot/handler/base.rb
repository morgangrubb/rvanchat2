module Bot
  module Handler
    class Base
      def initialize(options = {})
        @options = options
      end

      def process(action, message, params)
        return unless enabled?

        case action
        when :join_room       then join_room(message, params)
        when :leave_room      then leave_room(message, params)
        when :public_message  then public_message(message, params)
        when :private_message then private_message(message, params)
        end
      end

      def join_room(message, params)
        noop
      end

      def leave_room(message, params)
        noop
      end

      def public_message(message, params)
        noop
      end

      def private_message(message, params)
        noop
      end

      def say(message, options = {})
        if options[:user_name]
          post message => options[:user_name]
        else
          post message
        end
      end

      private

      def redis
        @redis ||= @options[:redis]
      end

      def log_message(message)
        $stderr.puts "#{message.time} | <#{message.user_name}> #{message.text}"
      end

      def log(comment)
        $stderr.puts comment
      end

      def enabled?
        @options[:controller].enabled? self.class.name.underscore.split('_').last
      end

    end
  end
end
