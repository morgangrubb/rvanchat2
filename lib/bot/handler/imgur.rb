require 'imgur'

module Bot
  module Handler
    class Imgur < Bot::Handler::Base

      def public_message(message, params)
        message.links.each do |link|
          next unless link.parsed.host =~ /\bimgur.com$/
          link.processed!

          case link.parsed.path
          when %r(^/([A-Za-z0-9]+)(\..*)?$)
            image = imgur_client.get_image($1)
            extension_included = $2.present?

            if image && image.link.present?
              include_link =
                if extension_included
                  include_link = image.html_link
                else
                  include_link = image.link
                end

              if image.title.present?
                say "#{include_link}\nimgur.com: #{image.title}\n#{image.description}"
              else
                say "imgur.com: #{include_link}"
              end
            end
          when %r(^/(a|album)/([A-Za-z0-9]+)$)
            # TODO
          when %r(^/(g|gallery)/([A-Za-z0-9]+)$)
            # TODO
          end
        end
      end

      def imgur_client
        @imgur_client ||= ::Imgur::Client.new("8bdaf2f40a595b6")
      end

    end
  end
end
