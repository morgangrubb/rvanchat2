module Bot
  module Handler
    class Background < Bot::Handler::Base

      def private_message(message, params)
        if message.from_admin?
          if message.text =~ /^!background (.*)$/
            message.processed!

            command = $1
            case command
            when /^list$/
              ::Background.all.each do |background|
                say_background background, message.user_name
              end
            when /^add ([^\s]+)(?:\s(.*))?$/
              if message.links.any?
                message.links.first.processed!
                ::Background.create(url: message.links.first.to_s, credit: $2).create!
                say_background background, message.user_name
              end
            when /^remove ([0-9]+)/
              ::Background.where(id: $1).first.try(:destroy)
              say "Removed", user_name: message.user_name
            end
          end
        end
      end

      def say_background(background, user_name)
        say "#{background.id} - #{background.credit}\n#{background.url}", user_name: user_name
      end

      def describe_commands(message)
        [
          "Manage backgrounds with:",
          "!background list",
          "!background add <url> <credit>",
          "!background remove <id>",
          "Backgrounds should be under 100kb for sanity"
        ].join("\n")
      end

    end
  end
end
