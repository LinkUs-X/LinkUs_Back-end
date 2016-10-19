class CardsController < ApplicationController
  
  before_action :set_card, only: [:show, :edit, :update, :destroy]

  def show
    @cards = Card.find(params[:id])
  end

  def index
  	@cards = Card.all.order(:user_id)
  end

  # GET /cards/1/edit
  def edit
  end

  # PATCH/PUT /cards/1
  # PATCH/PUT /cards/1.json
  def update
    respond_to do |format|
      if @card.update(card_params)
        format.html { redirect_to cards_url, notice: 'Card was successfully updated.' }
        format.json { render :show, status: :ok, location: @card }
      else
        format.html { render :edit }
        format.json { render json: @card.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cards/1
  # DELETE /cards/1.json
  def destroy
    @card.destroy
    respond_to do |format|
      format.html { redirect_to cards_url, notice: 'Card was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_card
      @card = Card.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def card_params
      params.require(:card).permit(:user_id, :card_name, :first_name, :last_name,:phone_nbr, :facebook_link, :linkedin_link, :email, :street, :city, :postal_code, :country, :description, :picture_url)
    end
end