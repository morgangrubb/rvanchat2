module Bot
  module Handler
    class Twitter < Bot::Handler::Base

      # TITLE_MAX_LENGTH = 100

      # TWITTER_BASE   = "http://twitter.com/statuses/show/"
      # TWITTER_FORMAT = "json"

      # TWITTER_REGEX  = /https?:\/\/twitter.com\/[^\/]+\/status\/(\d+)/
      # TWITTER_FAIL   = "Twitter failure. :("

      def public_message(message, params)
        #         when TWITTER_REGEX
        #           $stderr.puts "it's a twitter url! fetch it!"
        #           msg = twitter({:id => uri.to_s})
        #           post msg ? msg : TWITTER_FAIL


      end

      # def twitter(params)
      #   twitter_id = nil
      #   params[:id].gsub!(/\s/, '')
      #   if params[:id] =~ TWITTER_REGEX
      #     twitter_id = $1
      #   elsif !(params[:id] =~ /\A\d+\z/)
      #     return "Couldn't find a twitter id."
      #   else
      #     twitter_id = params[:id]
      #   end

      #   if twitter_id
      #     begin
      #       tweet = twitter_client.status(twitter_id)
      #       "[#{tweet.created_at}] #{tweet.user.name}: #{tweet.full_text}"
      #     rescue OpenURI::HTTPError => e
      #       "Not a link? Twitter failure? Pete only knows."
      #     end
      #   end
      # end

    end
  end
end
