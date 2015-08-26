require 'imgur'

module Bot
  module Handler
    class Imgur < Bot::Handler::Base

      def public_message(message, params)
        message.links.each do |link|
          if link =~ %r(imgur.com/([A-Za-z0-9]+)$)
            image = imgur_client.get_image($1)
            if image && image.link.present?
              link.processed!
              if image.title.present?
                say "#{image.title}: #{image.link}\n#{image.description}\n#{image.html_link}"
              else
                say "Link to the image: #{image.link}"
              end
            end
          end
        end
      end

      def imgur_client
        @imgur_client ||= ::Imgur::Client.new("8bdaf2f40a595b6")
      end

    end
  end
end
