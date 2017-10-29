require 'dropbox'
require 'ftp_images'

class BackgroundsController < ApplicationController
  def gallery
    if FtpImages.enabled?
      client = FtpImages.new
      render json: client.images
    elsif Dropbox.enabled?
      client = Dropbox.new
      @images = client.images
    else
      @images = Background.all
    end
  end

  def random
    if FtpImages.enabled?
      client = FtpImages.new
      render json: client.images.sample
    elsif Dropbox.enabled?
      client = Dropbox.new
      render json: client.images.sample
    else
      count = Background.count
      if count.zero?
        render json: {
          url: view_context.image_path("footer_lodyas.png"),
          credit: ""
        }
      else
        render json: Background.offset(rand(Background.count)).first
      end
    end
  end

  def dropbox
    begin
      client = Dropbox.new
      if params[:path]
        send_data client.get_image_data(params[:path]), type: "image/jpeg", disposition: 'inline'
      else
        send_data client.get_random_image_data, type: "image/jpeg", disposition: 'inline'
      end
    rescue => e
      Rails.logger.fatal "#{e.class.name}: #{e.message}\n#{e.backtrace[0..10].join("\n")}"
      send_data Rails.root.join('app/assets/images/footer_lodyas.png').read, type: "image/png", disposition: 'inline'
    end
  end

  def ftp
    begin
      client = FtpImages.new
      if params[:path]
        send_data client.get_image_data(params[:path]), type: "image/jpeg", disposition: 'inline'
      else
        send_data client.get_random_image_data, type: "image/jpeg", disposition: 'inline'
      end
    rescue => e
      Rails.logger.fatal "#{e.class.name}: #{e.message}\n#{e.backtrace[0..10].join("\n")}"
      send_data Rails.root.join('app/assets/images/footer_lodyas.png').read, type: "image/png", disposition: 'inline'
    end
  end
end
