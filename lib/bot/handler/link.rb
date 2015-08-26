module Bot
  module Handler
    class Link < Bot::Handler::Base
      BLOCKED_HOSTS = %w[ localhost 127.0.0.1 ]

      DEFAULT_ENCODINGS = %w[ UTF-8 UTF8 utf8 utf-8 ]

      TITLE_MAX_LENGTH = 180

      def public_message(message, params)
        return if message.command?

        message.links.each do |link|
          next if link.processed?
          link.processed!

          # Now fetch and say something about the link
          #
          # This thing was lifted from the Jabbot example and is awful. Maybe
          # someday I'll find the time to replace it.
          begin
            uri = link.parsed
            if !BLOCKED_HOSTS.include?(uri.host)
              req = fetch(uri) # handle redirects
              doc = Nokogiri::HTML(req.body)
              if req.header['content-type'] =~ /text/i
                http_equiv = doc.css("meta[http-equiv=content-type]").first
                if http_equiv && content = http_equiv.attributes['content']
                  send_encoding = content.to_s.gsub(/^.+charset=/, '')
                end

                if !send_encoding && req.header['content-type'] =~ /^.+charset=(.+)/i
                  send_encoding = $1
                end

                if doc && title = doc.css("title")
                  if !title.empty?
                    title = title[0].content.gsub(/\r/, '').gsub(/\n/, ' ').gsub(/\s+/, ' ')
                    if title.length > TITLE_MAX_LENGTH
                      title = title[0, TITLE_MAX_LENGTH] + '...'
                    end

                    if send_encoding && !DEFAULT_ENCODINGS.include?(send_encoding)
                      title = title.encode(DEFAULT_ENCODINGS.first)
                    end

                    say "Title: #{title} (at #{uri.host})"
                  else
                    say "Title: <empty> (at #{uri.host})"
                  end
                end
              end
            end
          rescue SocketError => e
            if e.message == "getaddrinfo: No address associated with hostname"
              say "Couldn't resolve #{url}"
            else
              $stderr.puts "We're on line #{__LINE__}"
              $stderr.puts e.inspect
              $stderr.puts uri.inspect
              $stderr.puts message.inspect
            end
          rescue Exception => e
            $stderr.puts "We're on line #{__LINE__}"
            $stderr.puts e.inspect
            $stderr.puts uri.inspect
            $stderr.puts message.inspect
          end
        end
      end

      private

      # example taken from
      # http://ruby-doc.org/stdlib/libdoc/net/http/rdoc/classes/Net/HTTP.html
      # handles redirects correctly
      def fetch(uri_str, limit = 10)
        $stderr.puts "#{uri_str.to_s}, #{limit}"

        # You should choose better exception.
        #  Nope, I won't.
        raise ArgumentError, 'HTTP redirect too deep' if limit == 0

        response = Net::HTTP.get_response(uri_str.kind_of?(URI) ? uri_str : URI.parse(uri_str))
        case response
        when Net::HTTPSuccess     then response
        when Net::HTTPRedirection then fetch(response['location'], limit - 1)
        else
          response.error!
        end
      end

    end
  end
end
