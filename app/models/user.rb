class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook, :google_oauth2]

  validates :xmpp_username, :xmpp_password, presence: true

  has_many :room_users, dependent: :destroy
  has_many :rooms, through: :room_users

  before_create :add_to_default_rooms
  after_create :register_with_prosody

  after_update :handle_prosody_data

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email
      user.name = auth.info.name.presence || auth.info.nickname
      user.password = Devise.friendly_token[0,20]

      # Now allocate xmpp data
      names =
        [auth.info.first_name.presence, auth.info.name.presence, auth.info.nickname.presence].
          compact.collect { |s| s.downcase.gsub(/\s+/, '-').gsub(/[^a-z-]/, '') }

      # names =
      #   [auth.info.first_name.presence, auth.info.name.presence, auth.info.nickname.presence].
      #     compact.collect { |s| s.downcase.gsub(/[^a-z]/, '') }

      user.xmpp_username =
        names.find { |name| !User.unscoped.where(xmpp_username: name).exists? }

      # TODO: Find much better ways to generate these
      user.xmpp_username ||= (0...8).map { (65 + rand(26)).chr }.join.downcase
      user.xmpp_password = (0...8).map { (65 + rand(26)).chr }.join.downcase
    end
  end

  def add_to_default_rooms
    self.rooms += Room.where(default: true).all
  end

  def register_with_prosody
    %x(sudo prosodyctl register #{xmpp_username} #{XMPP_HOST} #{xmpp_password})
  end

  def jid
    "#{xmpp_username}@#{XMPP_HOST}"
  end

  def handle_prosody_data
    User.write_prosody_data
  end

  def self.write_prosody_data
    Rails.root.join('config/prosody/group_bookmarks').open('w') do |file|
      Room.all.each do |room|
        file << "[#{room.jid}]\n"
        room.users.each do |user|
          file << "#{user.jid}\n"
        end
      end
    end

    Rails.root.join('config/prosody/admins.cfg.lua').open('w') do |file|
      file << "admins = {\n"
      User.where(admin: true).each do |user|
        file << %(  "#{user.jid}";\n)
      end
      file << "}\n"
    end

    %x(sudo prosodyctl reload)
  end
end
