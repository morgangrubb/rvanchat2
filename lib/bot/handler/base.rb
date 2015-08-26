module Bot
  module Handler
    class Base
      def initialize(options = {})
        @options = options
      end

      def receive(action, message, params)
        case action
        when :join_room       then join_room(message, params)
        when :leave_room      then leave_room(message, params)
        when :public_message  then public_message(message, params)
        when :private_message then private_message(message, params)
        when :subject_change  then subject_change(message, params)
        end
      end

      def join_room(message, params)
        # Do nothing
      end

      def leave_room(message, params)
        # Do nothing
      end

      def public_message(message, params)
        # Do nothing
      end

      def private_message(message, params)
        # Do nothing
      end

      def subject_change(message, params)
        # Do nothing
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

      def controller
        @options[:controller]
      end

    end
  end
end
