class UserService::Update < UserService::Base

  before_save :set_groups
  before_save :set_rooms

  after_save :register_with_prosody
  after_save :update_vcard
  after_save :publish_prosody_config
  after_save :reload_prosody

  def set_groups
    user.groups = Group.where(default: true).all
  end

  def set_rooms
    user.rooms = Room.where(default: true).all
  end

  def register_with_prosody
    ProsodyService.register(user)
  end

  def update_vcard
    begin
      VCardUpdaterService.new(user).update
    rescue => e
      Rails.logger.fatal "#{e.message}\n  #{e.backtrace[0..10].join("\n  ")}"
    end
  end

  def publish_prosody_config
    ProsodyService.publish unless options[:skip_prosody]
  end

  def reload_prosody
    ProsodyService.reload unless options[:skip_prosody]
  end

end
