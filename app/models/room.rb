class Room < ActiveRecord::Base
  has_many :room_users, dependent: :destroy
  has_many :users, through: :room_users

  validates :name, presence: true

  def jid
    "#{name}@#{CONFERENCE_HOST}"
  end
end
