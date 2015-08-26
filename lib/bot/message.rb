module Bot
  class Message
    def initialize(jabbot_message)
      @jabbot_message = jabbot_message
      @processed = false

      if jabbot_message.is_a?(ExtendedChatMessageNick)
        $stderr.puts "---------------------------------------------------------"
        $stderr.puts "Jabber resource"
        $stderr.puts jabbot_message.jabber_message_resource.inspect
        $stderr.puts "---------------------------------------------------------"
      end
    end

    def user_name
      @jabbot_message.user
    end

    def user
      return @user if defined? @user
      @user = User.where(xmpp_username: @jabbot_message.user).first
    end

    def links
      return @links if defined? @links
      @links =
        URI.extract(@jabbot_message.text).collect { |url| Link.new(url) }
    end

    def processed?
      @processed
    end

    def processed!
      @processed = true
    end

    def command?
      return @command if defined? @command
      @command = @jabbot_message.text =~ /\A\s*!\w+/
    end

    private

    def method_missing(method_id, *args)
      @jabbot_message.send method_id, *args
    end
  end

  class Link
    def initialize(url)
      @url = url
      @processed = false
    end

    def parsed
      @parse ||= URI.parse(@url)
    end

    def processed?
      @processed
    end

    def processed!
      @processed = true
    end
  end
end
