class LinksController < ApplicationController

  before_action :set_link, only: [:show, :update, :destroy]  

  def show
  	@links = Link.find(params[:id])
  end

  def index
  	@links = Link.all.order(:user_id)
  end

  # DELETE /links/1
  # DELETE /links/1.json
  def destroy
    @link.destroy
    respond_to do |format|
      format.html { redirect_to links_url, notice: 'Link was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_link
      @link = Link.find(params[:id])
    end

end