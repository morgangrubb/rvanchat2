module Bot
  module Handler
    class Whois < Bot::Handler::Base

      # Don't describe admin commands for now
      def describe_commands(message)
        if message.from_admin?
          [
            "Describe a user:",
            "!whois <user_name>"
          ].join("\n")
        end
      end

      def private_message(message, params)
        if message.from_admin?
          case message.text
          when /^!whois (.*)/
            xmpp_username = $1
            user = User.where(xmpp_username).first
            if user
              pieces =
                [
                  user.name.presence,
                  user.email.presence,
                  user.image_url.presence,
                ]

              if user.auth_info.urls.present?
                user.auth_info.urls.each do |u|
                  pieces << u.join(" -> ")
                end
              end

              pieces.compact!

              say "On #{xmpp_username}:\n#{pieces.join("\n")}", user_name: message.user_name
            else
              say "I couldn't find anyone by the name '#{xmpp_username}'", user_name: message.user_name
            end
          when /^!whois/
            say describe_commands(message), user_name: message.user_name
          end
        end
      end

    end
  end
end
