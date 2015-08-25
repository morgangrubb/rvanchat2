REDIS_CONFIG = YAML.load_file(Rails.root.join('config/redis.yml'))[Rails.env]

module Rvanchat
  def self.redis(force_new = false, options = {})
    if force_new
      Redis.new(REDIS_CONFIG.merge(options.stringify_keys))
    else
      @redis ||= Redis.new(REDIS_CONFIG.merge(options.stringify_keys))
    end
  end
end
