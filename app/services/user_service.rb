class UserService
  class << self

    def update(user, options = {})
      UserService::Update.new(user, options)
    end

  end
end
