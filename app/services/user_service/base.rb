class UserService::Base
  extend ActiveModel::Callbacks

  define_model_callbacks :save

  attr_reader :user, :options

  def initialize(user, options = {})
    @user    = user
    @options = options
  end

  def save
    run_callbacks :save do
      @user.save!
    end
  end
end
