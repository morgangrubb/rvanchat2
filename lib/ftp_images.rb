class FtpImages
  class << self
    def enabled?
      true
    end

    def folder
      Pathname.new("/home/chris")
    end

    def version_bumper
      1
    end
  end

  def initialize
    #
  end

  def get_image_data(name)
    Rvanchat.fetch "#{cache_key}/#{name}", expires_in: 1.hour do
      found = images.find { |i| Pathname.new(i.url).basename.to_s == name }
      if found
        Pathname.new(found.url).read
      end
    end
  end

  def images
    Rvanchat.fetch "#{cache_key}", expires_in: 1.minute do
      files.select { |f| f.extname =~ /\.jpe?g$/i } .collect do |f|
        url = "//#{XMPP_HOST}/ftp?" + { name: f.basename }.to_query
        Background.new({ url: f, credit: Dropbox.credit })
      end
    end
  end

  def files(path = self.class.folder)
    all_files = []

    path.children.each do |child|
      if child.symlink?
        next
      elsif child.directory?
        all_files += files(child)
      else
        all_files << child
      end
    end

    all_files
  end

  def cache_key
    @cache_key ||=
      [
        "ftp_images",
        self.class.version_bumper
      ].compact.join('/')
  end

  def get_random_image
    images.sample
  end

  def get_random_image_data
    get_image_data(Pathname.new(get_random_image.url).basename)
  end
end
