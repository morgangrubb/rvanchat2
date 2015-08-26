module Bot
  class HandlerController
    attr_reader :handlers

    def initialize(options = {})
      @options = options
      @handlers = {}
    end

    def register(name, handler)
      @handlers[name] = handler.new(options.merge(controller: self))
    end

    def receive(event, bot_message, params)
      enabled_handlers.each do |name|
        next unless handlers[name]
        handlers[name].receive(event, bot_message, params)
      end
    end

    def all_handlers
      @handlers.keys
    end

    def enable_handler(name)
      redis.sadd("enabled_handlers", name)
    end

    def disable_handler(name)
      redis.srem("enabled_handlers", name)
    end

    # The order of the returned elements is set from the first array so I'm
    # using array & as an ordered filter.
    def enabled_handlers
      @handlers.keys & redis.smembers("enabled_handlers")
    end

    def disabled_handlers
      @handlers.keys - redis.smembers("enabled_handlers")
    end

    private

    def redis
      @redis ||= @options[:redis]
    end
  end
end
