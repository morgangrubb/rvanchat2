class ChatController < ApplicationController
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

  def candy
    render layout: "empty"
  end

  def register
    #
  end
end
