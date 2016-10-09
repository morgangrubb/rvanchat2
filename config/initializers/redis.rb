REDIS_CONFIG = YAML.load_file(Rails.root.join('config/redis.yml'))[Rails.env]

module Rvanchat
  def self.redis(force_new = false, options = {})
    if force_new
      Redis.new(REDIS_CONFIG.merge(options.stringify_keys))
    else
      @redis ||= Redis.new(REDIS_CONFIG.merge(options.stringify_keys))
    end
  end

  def self.fetch(key, options = {})
    raise "Block required." unless block_given?

    # Does the data exist in the cache?
    if (data = self.read(key)).present?
      return data
    end

    data = yield

    self.write(key, data, options)

    data
  end

  def self.read(key)
    puts "read: #{key}"
    if data = self.redis.get(key)
      puts "found"
      return Marshal.load(data)
    end
  end

  def self.write(key, data, options = {})
    redis_options = {}
    if options[:expires_in]
      redis_options[:ex] = options[:expires_in].seconds
    end

    # Now cache it and return it
    self.redis.set(key, Marshal.dump(data), redis_options)

    true
  end
end
