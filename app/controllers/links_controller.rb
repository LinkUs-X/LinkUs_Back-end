class LinksController < ApplicationController
  

  def show
  	@user = User.find(params[:id])
  	@links = Link.where("user_id = ?", params[:id]).order(:meeting_date)
  end

  def index
  	@links = Link.all.order(:user_id)
  end
end