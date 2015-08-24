class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :room

  has_many :links

  # Currently the text of the message is being CGI::Encoded since it appears
  # to be invalid.
end
