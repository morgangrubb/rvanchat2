class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook, :google_oauth2]

  validates :xmpp_username, :xmpp_password, presence: true

  serialize :auth_info

  has_many :room_users, dependent: :destroy
  has_many :rooms, through: :room_users

  has_many :group_users, dependent: :destroy
  has_many :groups, through: :group_users

  def self.from_omniauth(auth)
    user =
      where(email: auth.info.email).first_or_initialize do |user|
        user.password = Devise.friendly_token[0,20]

        # Allocate one-time xmpp data
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

    # Update regular user data
    user.auth_info = auth.info

    user.provider = auth.provider
    user.uid = auth.uid
    user.email = auth.info.email
    user.image_url  = auth.info.image
    user.name = auth.info.name.presence || auth.info.nickname

    user.save!
    user
  end

  def jid
    "#{xmpp_username}@#{XMPP_HOST}"
  end

end
