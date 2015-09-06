class BackgroundsController < ApplicationController
  def random
    render json: Background.offset(rand(Background.count)).first
  end
end
