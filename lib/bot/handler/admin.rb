module Bot
  module Handler
    class Admin < Bot::Handler::Base

      def initialize(*args)
        super(*args)

        # Now empty the admin nick list. Just to be on the safe side.
        redis.del("channel_admins")
      end

      def join_room(message, params)
        # Do nothing
      end

      def leave_room(message, params)
        redis.srem("channel_admins", message.user_name)
      end

      def public_message(message, params)
        message.from_admin! if redis.smember("channel_admins", message.user_name)
      end

      def private_message(message, params)
        message.from_admin! if redis.smember("channel_admins", message.user_name)

        case message.text
        when /^!auth (.*)$/
          message.processed!

          if user = User.where(admin_token: $1).first
            redis.sadd("channel_admins", message.user_name)
            say "Authenticated as channel admin", user_name: message.user_name
          else
            say "Didn't recognise the supplied authkey", user_name: message.user_name
          end
        end

      end

      def subject_change(message, params)
        message.from_admin! if redis.smember("channel_admins", message.user_name)
      end

    end
  end
end
