YT_CONFIG = YAML.load_file(Rails.root.join('config/yt.yml'))[Rails.env].with_indifferent_access

Yt.configure do |config|
  config.api_key = YT_CONFIG[:api_key]
end
