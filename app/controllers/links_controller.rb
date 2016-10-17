class LinksController < ApplicationController
  

  def showlinks
  	@links = Link.find(params[:user_id]).order(:meeting_date).all
  end

  def index
  	@links = Link.order(:user_id).all
end
