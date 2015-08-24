class LinksController < ApplicationController
  def index
    @links = Link.page(params[:page]).per(20).group("message_id").order("created_at DESC")
  end
end
