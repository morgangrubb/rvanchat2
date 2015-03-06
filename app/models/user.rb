class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook, :google_oauth2]

  validates :xmpp_username, :xmpp_password, presence: true

  after_create :register_with_prosody

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email
      user.name = auth.info.name.presence || auth.info.nickname
      user.password = Devise.friendly_token[0,20]

      # Now allocate xmpp data
      # names =
      #   [auth.info.name.presence, auth.info.nickname.presence].
      #     compact.collect { |s| s.downcase.gsub(/\s+/, '-').gsub(/[^a-z-]/, '') }

      names =
        [auth.info.first_name.presence, auth.info.name.presence, auth.info.nickname.presence].
          compact.collect { |s| s.downcase.gsub(/[^a-z]/, '') }

      user.xmpp_username =
        names.find { |name| !User.unscoped.where(xmpp_username: name).exists? }

      # TODO: Find much better ways to generate these
      user.xmpp_username ||= (0...8).map { (65 + rand(26)).chr }.join.downcase
      user.xmpp_password = (0...8).map { (65 + rand(26)).chr }.join.downcase
    end
  end

  def register_with_prosody
    # Register the user with prosody
    command = %(sudo prosodyctl register #{xmpp_username} #{XMPP_HOST} #{xmpp_password})
    Rails.logger.fatal command
    %x(#{command})

    # Add the user to the auto-join set

  end
end
