class Dropbox

  def self.enabled?
    Rvanchat.read('dropbox/enabled') || false
  end

  def self.enabled!
    Rvanchat.write('dropbox/enabled', true)
  end

  def self.disabled!
    Rvanchat.write('dropbox/enabled', false)
  end

  def self.access_token
    Rvanchat.read('dropbox/access_token')
  end

  def self.access_token=(value)
    Rvanchat.write('dropbox/access_token', value)
  end

  def self.shared_folder
    Rvanchat.read('dropbox/shared_folder')
  end

  def self.shared_folder=(value)
    Rvanchat.write('dropbox/shared_folder', value)
  end

  def initialize
  end

  def access_token
    @access_token ||= self.class.access_token
  end

  def shared_folder
    @shared_folder ||= self.class.shared_folder
  end

  def cache_key
    @cache_key ||= Digest::MD5.hexdigest([self.class.shared_folder, self.class.access_token].compact.join('-'))
  end

  def images
    files.collect { |f| f if f =~ /\.jpe?g$/i }.compact
  end

  def files
    Rvanchat.fetch "dropbox/files/#{cache_key}", expires_in: 90.minutes do
      list_shared_folder.body["contents"].collect { |f| f['path'] }
    end
  end

  def list_shared_folder
    Unirest.post('https://api.dropbox.com/1/metadata/link', {
      headers: {
        "Authorization" => "Bearer #{access_token}"
      },
      parameters: {
        link: shared_folder
      }
    })
  end

  def get_shared_link_data(path)
    Rvanchat.fetch "dropbox/data/#{cache_key}/#{path}", expires_in: 1.week do
      Unirest.post('https://content.dropboxapi.com/2/sharing/get_shared_link_file', {
        headers: {
          "Authorization" => "Bearer #{access_token}",
          "Content-Type" => "",
          "Dropbox-API-Arg" => {
            url: shared_folder,
            path: path
          }.to_json
        }
      })
    end
  end

  def get_image_data(path)
    get_shared_link_data(path)
  end

  def get_random_image_data
    get_image_data(images.sample)
  end
end
