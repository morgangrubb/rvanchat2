require 'dropbox'

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
                ::Background.create(url: message.links.first.parsed.to_s, credit: $2).create!
                say_background background, message.user_name
              end
            when /^remove ([0-9]+)/
              ::Background.where(id: $1).first.try(:destroy)
              say "Removed", user_name: message.user_name
            when /^source (dropbox|urls)\s*$/
              if $1 == 'dropbox'
                Dropbox.enabled!
                say "Dropbox backgrounds enabled."
              else
                Dropbox.disabled!
                say "Dropbox backgrounds disabled."
              end
            when /^dropbox\s*$/
              say "The current shared folder url is: #{Dropbox.shared_folder}"
            when /^dropbox\s+list\s*$/
              begin
                files = Dropbox.new.files
                say "I found the following files in the shared dropbox folder:\n#{files.join("\n")}"
              rescue => e
                say "There was a problem reading files from the shared folder."
              end
            when %r(^dropbox\s+(https?://.*?)\s*$)
              Dropbox.shared_folder = $1
              say "Shared folder updated. No sanity check performed so I hope you got it right."
            end
          end
        end
      end

      def say_background(background, user_name)
        say "#{background.id} - #{background.credit}\n#{background.url}", user_name: user_name
      end

      def describe_commands(message)
        if message.from_admin?
          [
            "Manage backgrounds with:",
            "!background list",
            "!background add <url> <credit>",
            "!background remove <id>",
            "",
            "Experimental:",
            "!background source [dropbox|urls]",
            "!background dropbox",
            "!background dropbox list",
            "!background dropbox <url for shared folder>",
            "",
            "Backgrounds should be under 100kb for sanity"
          ].join("\n")
        end
      end

    end
  end
end
