class CardsController < ApplicationController
  

  def show
  	@user = User.find(params[:id])
  	
  	@cards = Card.where("user_id = ?", params[:id]).order(:user_id)

  end

  def index
  	@cards = Card.all.order(:user_id)
  end
end