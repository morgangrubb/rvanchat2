module Bot
  module Handler
    class Seen < Bot::Handler::Base

      # Kinda doesn't work if you change nick and we can't recognise the user
      # any more. Need to figure out a better solution for that.
      def join_room(message, params)
        user = message.user

        if user.present?
          redis.hset "last_seen", user.id, Time.now.to_i

          if !redis.sismember("welcomed", user.id)
            redis.sadd("welcomed", user.id)
            say "Hi, #{message.user_name}. Welcome to rvanchat."
          elsif !redis.exists("welcome_back:#{user.id}")
            redis.setex("welcome_back:#{user.id}", 3.days, true)
            say "Hi, #{message.user_name}. Welcome back."
          end
        end
      end

    end
  end
end
