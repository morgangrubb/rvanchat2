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

  def self.credit
    Rvanchat.read('dropbox/credit')
  end

  def self.credit=(value)
    Rvanchat.write('dropbox/credit', value)
  end

  def initialize
  end

  def access_token
    @access_token ||= self.class.access_token
  end

  def shared_folder
    @shared_folder ||= self.class.shared_folder
  end

  def credit
    @credit ||= self.class.credit
  end

  def version_bumper
    1
  end

  def cache_key
    @cache_key ||=
      Digest::MD5.hexdigest([
        version_bumper,
        self.class.shared_folder,
        self.class.access_token
      ].compact.join('-'))
  end

  def images
    Rvanchat.fetch "dropbox/images/#{cache_key}", expires_in: 90.minutes do
      files.select { |f| f['path'] =~ /\.jpe?g$/i } .collect do |f|
        url = "//#{XMPP_HOST}/dropbox?" + { path: f['path'], rev: f['rev'] }.to_query
        Background.new({ url: url, credit: credit })
      end
    end
  end

  def files
    Rvanchat.fetch "dropbox/files/#{cache_key}", expires_in: 90.minutes do
      list_shared_folder.body["contents"]
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
    Rvanchat.fetch "dropbox/data/#{cache_key}/#{path}", expires_in: 1.month do
      response =
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

      if response.code == 200
        response.raw_body
      else
        raise response.raw_body
      end
    end
  end

  def get_image_data(path)
    get_shared_link_data(path)
  end

end
