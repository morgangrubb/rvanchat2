class CallbacksController < ApplicationController
  def facebook
    @user = User.from_omniauth(request.env["omniauth.auth"])
    after_auth @user
  end

  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])
    after_auth @user
  end

  private

  # TODO: Make a job out of this. Queue up operations. Reload prosody after
  # changing the config.
  def after_auth(user)

    # We're done here
    sign_in_and_redirect user
  end
end
