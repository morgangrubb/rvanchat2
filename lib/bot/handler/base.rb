module Bot
  module Handler
    class Base
      def initialize(options = {})
        @options = options
      end

      def describe_commands(message)
        nil
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
        options.reverse_merge! record: false

        if options[:user_name]
          post message => options[:user_name]
        else
          post message
        end

        if options[:record]
          text =
            if options[:record] === true
              message
            else
              options[:record]
            end

          # Insert this image into the link log with the command that was issued.
          stored_message =
            ::Message.create(
              user_name: "@wopr",
              user_id: nil,
              room_name: @options[:room].name,
              room_id: @options[:room].id,
              text: text
            )

          # And fetch any links in the recorded message
          links = URI.extract(text).collect { |url| Link.new(url) }
          links.each do |link|
            ::Link.create(
              message_id: stored_message.id,
              host: link.parsed.host,
              url: link.parsed.to_s
            )
          end

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
