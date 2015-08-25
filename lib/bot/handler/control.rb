module Bot
  module Handler
    class Control < Bot::Handler::Base

      def private_message(message, params)
        if message.user.admin?
          case message.text
          when /^!enable (.*)$/
            enable $1
            say "Enabling #{$1}", user_name: message.user_name
          when /^!disable (.*)$/
            disable $1
            say "Disabling #{$1}", user_name: message.user_name
          when /^!handlers$/
            say "Handling #{handlers.join(", ")}", user_name: message.user_name
          end
        end
      end

      def handlers
        redis.smembers("enabled_handlers") - %w(help control)
      end

      def enabled?(handler)
        return true if %w(help control)
        redis.sismember("enabled_handlers", handler)
      end

      def enable(handler)
        redis.sadd("enabled_handlers", handler)
      end

      def disable(handler)
        redis.srem("enabled_handlers", handler)
      end

    end
  end
end
