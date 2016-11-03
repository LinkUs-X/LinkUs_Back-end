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
 
  # Create a link request: @user is an existing user sending a contact request.
  # POST request: /users/:id/createrequest/
  def createrequest
    # We use default parameters for position of link request
    # while waiting for another functionality to be implemented.
    @default_lat = 0
    @default_lng = 0
    
    # Retrieve existing users from URL parameters:
    @user = User.find(params[:id])

    # Retrieve card id of @user:
    @user_card_id = Card.find_by(user_id: @user.id).id

    # Create link request from @user:
    @link_request1 = LinkRequest.new(user_id: @user.id, card_id: @user_card_id, 
      lat: @default_lat, lng: @default_lng)

    # if 
      @link_request1.save
      flash[:notice] = "Contact request sent!"
      # Resque.enqueue(Destroyer, @link_request.id)
      # flash[:notice] = "Timeout"
      if LinkRequest.count >= 0 
        LinkRequest.find_each do |link_request| 
          #next if link_request == @link_request1
            @link_request = link_request
            
            if (@link_request1.created_at.utc - link_request.created_at.utc) < 10.seconds && 
              @link_request != @link_request1 
              if Link.where(user_id: @user.id, card_id: Card.find_by(user_id: 
                @link_request.user_id).id).exists?(conditions = :none) || Link.where(user_id: @link_request.user_id,
                 card_id: Card.find_by(user_id: @user_card_id).id).exists?(conditions = :none)
                flash[:notice] = "Links already exist!"
                @link_request1.delete
                @link_request.delete
                return
              else if Link.where(user_id: @user.id, card_id: Card.find_by(user_id: 
                @user_id).id).exists?(conditions = :none)
              end             
              if @link1 = Link.create(user_id: @user.id, card_id: Card.find_by(user_id: 
                @link_request.user_id).id , lat: @default_lat,lng: @default_lng, meeting_date: Time.now) &&
              @link2 = Link.create(user_id: @link_request.user_id, card_id: @user_card_id, lat: @default_lat,
               lng: @default_lng, meeting_date: Time.now)
                respond_to do |format| 
                 format.html { redirect_to users_url, notice: 'Links were successfully created.' }
                 format.json
                end
              else
               format.json { render json: @link1.errors, status: :unprocessable_entity }
               format.json { render json: @link2.errors, status: :unprocessable_entity }
              end
              @link_request1.delete
              @link_request.delete
            end
          # else
          # end
        end
      end
    # else
    #   flash[:notice] = "Unable to request contact."
    # end
  end

  # Accept a link request and create subsequently two links.
  # Note that in opposite to createrequest, @user is the user
  # to whom the link request was sent, and @contact is the user
  # who sent the link request.
  # POST request: /users/:id/updaterequest/:contact_id
  def updaterequest
    # We use default parameters for position and date of link.Note
    # that these should be the same as the parameters used for createrequest:
    @default_lat = 0
    @default_lng = 0
    @default_meeting_date = DateTime.new(2001, 2, 3, 4, 5, 6)
    
    # Retrieve existing users from URL parameters:
    @user = User.find(params[:id])
    @contact = User.find(params[:contact_id])

    # Retrieve card ids of @user and @contact:
    @user_card = Card.find_by(user_id: @user.id)
    @user_card_id = @user_card.id
    @contact_card = Card.find_by(user_id: @contact.id)
    @contact_card_id = @contact_card.id

    # Retrieve first name of @contact in order to confirm to whom 
    # @user just exchanged their card:
    @contact_first_name = @contact_card.first_name

    # Retrieve link request from @contact to @user. Now it is only used to
    # be deleted subsequently. However, later on it could be used for validation
    # so that links cannot be created without link requests, with an .accept method
    # for example.
    @link_request = LinkRequest.find_by(card_id: @user_card_id, user_id: @contact.id)

    # Accept link request and create two links: one to signal that
    # @user has the card of @contact, and the other one to signal
    # that @contact has the card of @user.

    flash[:notice] = "You and #{@contact_first_name} are now contacts!"
    @link1 = Link.new(user_id: @user.id, card_id: @contact_card_id, lat: @default_lat,
      lng: @default_lng, meeting_date: @default_meeting_date)
    @link1.save
    @link2 = Link.new(user_id: @contact.id, card_id: @user_card_id, lat: @default_lat,
      lng: @default_lng, meeting_date: @default_meeting_date)
    @link2.save
 
    # Destroy the link request once that @user and @contact are contacts:
    @link_request.destroy

    redirect_to user_path
  end

  # @user declines a link request from @contact. 
  # POST request: /users/:id/destroyrequest/:contact_id
  def destroyrequest
    @user = User.find(params[:id])
    @contact = User.find(params[:contact_id])

    @user_card = Card.find_by(user_id: @user.id)
    @user_card_id = @user_card.id

    @link_request = LinkRequest.find_by(card_id: @user_card_id, user_id: @contact.id)
    if @link_request.destroy
      flash[:notice] = "Request Declined."
      redirect_to user_path
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
      params.require(:card).permit(:card_name, :first_name, :last_name, :phone_nbr, :facebook_link, 
        :linkedin_link, :email, :street, :city, :postal_code, :country, :description, :picture_url)
    end

    # On ajoute les paramètres qu'on va envoyer avec le createlink
    # En plus des paramètres de base, il faut spécifier avec quelle card on se link
    # En revanche le userid vient dans l'URL qu'on query
    def link_params
      params.require(:link).permit(:card_id, :lat, :lng)
    end

    # I am not sure 
    def link_request_params
      params.require(:link_request).permit(:card_id, :user_id, :lat, :lng, :meeting_date)
    end
end