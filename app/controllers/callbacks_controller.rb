require 'open-uri'

class CallbacksController < ApplicationController
  def facebook
    @user = User.from_omniauth(request.env["omniauth.auth"])
    after_auth @user
  end

  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])
    after_auth @user
  end

  def failure
    flash[:alert] = params[:message]
    redirect_to root_path
  end

  private

  # TODO: Make a job out of this. Queue up operations. Reload prosody after
  # changing the config.
  def after_auth(user)
    # Push the avatar (Just in case any clients support it)
    # AvatarUpdaterService.new(user).update

    # Set rooms, groups, etc.
    UserService.update(user).save

    # We're done here
    sign_in_and_redirect user
  end
end
