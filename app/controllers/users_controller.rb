class UsersController < ApplicationController
  
  # On ajoute la méthode createcard dans la liste des méthodes où on set le user au début
  before_action :set_user, only: [:show, :edit, :update, :destroy, :createcard, :createlink, :showcardsbyuser, :showlinksbyuser, :newcard, :newlink]

  # On saute une etape de securite si on appel CREATECARD en JSON
  skip_before_action :verify_authenticity_token, only: [:create, :createcard, :createlink]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/1/showcardsbyuser
  # GET /users/1/showcardsbyuser.json
  def showcardsbyuser
    @user = User.find(params[:id])
    
    @cards = Card.where("user_id = ?", params[:id]).order(:user_id)
  end

  # GET /users/1/showslinksbyuser
  # GET /users/1/showlinksbyuser.json
  def showlinksbyuser
    @user = User.find(params[:id])
    
    @links = Link.where("user_id = ?", params[:id]).order(:user_id)
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/newcard
  def newcard
    @user = User.find(params[:id])
    @card = Card.new
  end

  # GET /users/1/newlink
  def newlink
    @user = User.find(params[:id])
    @link = Link.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # POST /users/1/createcard.json
  def createcard
    # On crée un nouvel objet card à partir des paramètres reçus
    @card = Card.new(card_params)
    # On précise que cet object Card dépend du user concerné
    @card.user = @user

    respond_to do |format|
      if @card.save
        format.html { redirect_to users_url, notice: 'Card was successfully created.' }
        format.json
      else
        format.json { render json: @card.errors, status: :unprocessable_entity }
      end
    end
  end
 
  # Create a link request from user with id = params[:id].
  # POST request: /users/:id/createrequest/
  def createrequest
    # We use default parameters for position of link request
    # while waiting for another functionality to be implemented.
    lat = 0
    lng = 0
    
    # Retrieve current user's card_id from URL parameters:
    user_card = Card.find(params[:id])
    user = user_card.user
    user_card_id = user_card.id

    # Retrieve user_id:
    user_id = user.id

    # Create link request from user:
    link_request1 = LinkRequest.new(user_id: user_id, card_id: user_card_id, 
      lat: lat, lng: lng)

    if link_request1.save
      flash[:notice] = "Contact request sent!"
      # Future use: Resque.enqueue(Destroyer, @link_request.id)
      # flash[:notice] = "Timeout"
     
      # Iterate through all requests in database:
      LinkRequest.find_each do |link_request| 

        # Skip the current user:
        if link_request == link_request1 
          next
        end

        # Skip all requests not made within the last 15 seconds:
        if (link_request1.created_at.utc - link_request.created_at.utc) > 15.seconds
          next                 
        end

        # Check if the users already exchanged their cards in the past:
        if Link.where(user_id: user_id, card_id: Card.find_by(user_id: 
          link_request.user_id).id).exists?(conditions = :none) || Link.where(user_id: link_request.user_id,
           card_id: user_card_id).exists?(conditions = :none)
          flash[:notice] = "Links already exist!"
          return
        end

        # If all the tests were passed, the users exchange their cards:
        @link1 = Link.new(user_id: user_id, card_id: Card.find_by(user_id: 
          link_request.user_id).id , lat: lat,lng: lng, meeting_date: Time.now) 
        @link2 = Link.new(user_id: link_request.user_id, card_id: user_card_id, lat: lat,
          lng: lng, meeting_date: Time.now)
        if @link1.save && @link2.save
          respond_to do |format| 
           format.html { redirect_to users_url, notice: 'Links were successfully created.' }
           format.json
          end
          return
        else
          @links = [@link1, @link2]
          format.json { render json: @links.errors, status: :unprocessable_entity }
          return
        end   
      end
    else
      flash[:notice] = "Unable to request contact."
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:login, :password)
    end

    # On ajoute les paramètres qu'on va envoyer avec le createcard
    # Seulement les paramètres de base, le userid vient dans l'URL qu'on query
    def card_params
      params.require(:card).permit(:id, :card_name, :first_name, :last_name, :phone_nbr, :facebook_link, 
        :linkedin_link, :email, :street, :city, :postal_code, :country, :description, :picture_url)
    end

    # On ajoute les paramètres qu'on va envoyer avec le createlink
    # En plus des paramètres de base, il faut spécifier avec quelle card on se link
    # En revanche le userid vient dans l'URL qu'on query
    def link_params
      params.require(:link).permit(:card_id, :lat, :lng)
    end

    def link_request_params
      params.require(:link_request).permit(:card_id, :user_id, :lat, :lng, :meeting_date)
    end
end