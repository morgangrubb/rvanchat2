module Bot
  class Message
    def initialize(message)
      @message = message
      @processed = false
    end

    def user_name
      @message.user
    end

    def user
      return @user if defined? @user
      @user = User.where(xmpp_username: @message.user).first
    end

    def links
      return @links if defined? @links
      @links =
        URI.extract(@message.text).collect { |url| Link.new(url) }
    end

    def processed?
      @processed
    end

    def processed!
      @processed = true
    end

    private

    def method_missing(method_id, *args)
      @message.send method_id, *args
    end
  end

  class Link
    def initialize(url)
      @url = url
      @processed = false
    end

    def parsed
      @parse ||= URI.parse(url)
    end

    def processed?
      @processed
    end

    def processed!
      @processed = true
    end
  end
end
