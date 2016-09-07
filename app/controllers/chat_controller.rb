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
    @ajax_client_path =
      if params[:converse]
        converse_path
      else
        candy_path
      end
  end

  def converse
    render layout: "empty"
  end

  def reveal
    render layout: false
  end

  def candy
    if current_user.id == 3
      if params[:bosh4r]
        instance = Bosh4r::Session.new(current_user.jid, current_user.xmpp_password, bosh_url: "http://#{XMPP_HOST}/http-bind/")
        @credentials = {
          sid: instance.sid,
          jid: instance.jabber_id,
          rid: instance.rid
        }
      else
        @credentials =
          Bosh.initialize_session current_user.jid, current_user.xmpp_password, "http://#{XMPP_HOST}/http-bind/"
      end

      render layout: "empty"
    else
      render text: "<p><b>Currently broken. :(</b><br />Please use a chat client and the credentials available in the upper-right corner of the window.</p>".html_safe
    end

    # render layout: "empty"
  end

  def register
    #
  end

  def prebind
    credentials =
      Bosh.initialize_session current_user.jid, current_user.xmpp_password, "http://#{XMPP_HOST}/http-bind/"

    # render json: {
    #   jid: current_user[:jid],
    #   sid: credentials[:sid],
    #   rid: credentials[:rid]
    # }

    render json: credentials
  end

  private

  def default_chat_room
    case Rails.env
    when 'development' then 'main'
    when 'production' then 'chat'
    end
  end
  helper_method :default_chat_room

  def require_login
    unless user_signed_in?
      flash[:alert] = "You have to be signed in to see that"
      redirect_to register_path
    end
  end
end
