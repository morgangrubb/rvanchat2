class ChatController < ApplicationController

  before_filter :require_login, only: [:chat, :reveal, :candy]

  rescue_from Bosh::Error do |exception|
    flash[:alert] = exception.message
    redirect_to register_path
  end

  def index
    if user_signed_in?
      redirect_to chat_path
    else
      redirect_to register_path
    end
  end

  def chat
    #
  end

  def reveal
    render layout: false
  end

  def candy
    @credentials =
      Bosh.initialize_session current_user.jid, current_user.xmpp_password, "http://#{XMPP_HOST}/http-bind/"

    render layout: "empty"
  end

  def register
    #
  end

  private

  def require_login
    unless user_signed_in?
      flash[:alert] = "You have to be signed in to see that"
      redirect_to register_path
    end
  end
end
