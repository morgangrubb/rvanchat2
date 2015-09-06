module Bot
  module Handler
    class Youtube < Bot::Handler::Base

      def public_message(message, params)
        if message.text =~ /^!youtube$/
          message.processed!
        elsif message.text =~ /^!youtube (.+)$/
          message.processed!

          video = Yt::Collections::Videos.new.where(q: $1).first

          if video.present?
            string = ""
            string << "#{video.channel_title}: " if video.channel_title.present?
            string << video.title
            string << "\n"
            string << "https://www.youtube.com/watch?v=#{video.id}"

            say string
          else
            say "I couldn't find anything for '#{$1}'"
          end
        end
      end

      def describe_commands(message)
        examples = [
          "friday",
          "do the bartman",
          "robot chicken",
          "spaceballs"
        ]

        "Search for a specific youtube video with\n!youtube #{examples.sample}"
      end

    end
  end
end
