class WelcomeController < ApplicationController
  def index
    if user_signed_in?
      redirect_to candy_path
    else
      redirect_to register_path
    end
  end

  def register

  end
end
