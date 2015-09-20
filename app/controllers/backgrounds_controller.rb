class BackgroundsController < ApplicationController
  def random
    count = Background.count
    if count.zero?
      render json: {
        url: view_context.image_path("footer_lodyas.png"),
        credit: ""
      }
    else
      render json: Background.offset(rand(Background.count)).first
    end

  end
end
