class UsersController < ApplicationController
  
  # On ajoute la méthode createcard dans la liste des méthodes où on set le user au début
  before_action :set_user, only: [:show, :edit, :update, :destroy, :createcard, :createlink,
   :showcardsbyuser, :showlinksbyuser, :newcard, :newlink, :createrequest]

  # On saute une etape de securite si on appel CREATECARD en JSON
  skip_before_action :verify_authenticity_token, only: [:create, :createcard, :createlink, :createrequest]

  # GET /users
  # GET /users.json
  def index
    @users = User.all.order(:id)
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
 
  # Create a link request from current user.
  # POST request: /users/:id/createrequest/
  def createrequest
    # Create link request from user:
    link_request1 = LinkRequest.new(link_request_params)
    link_request1.link_created = false
    link_request1.user = @user

    @link_request1 = link_request1

    # Retrieve current user and his card:
    user_card = Card.find(@link_request1.card_id)
    user_card_id = user_card.id
    user = User.find(@link_request1.user_id)
    user_id = user.id

    if link_request1.save
      flash[:notice] = "Contact request sent!"
      # Future use: Resque.enqueue(Destroyer, @link_request.id)
      # flash[:notice] = "Timeout"
     
      # Iterate through all requests in database:
      LinkRequest.find_each do |link_request| 

        # Skip the current user:
        if link_request == @link_request1 || link_request.user_id == user_id
          next
        end

        # Skip all requests not made within the last 15 seconds:
        if (@link_request1.created_at.utc - link_request.created_at.utc) > 15.seconds
          next
        end                 

        # # Skip all requests not made within a 25 meters radius:
        # if shortDistance(link_request1.lat, link_request1.lng, link_request.lat, link_request.lng) > 25
        #   next
        # end

        # Check if the users already exchanged their cards in the past:
        if Link.where(user_id: user_id, card_id: Card.find_by(user_id: 
          link_request.user_id).id).exists?(conditions = :none) || Link.where(user_id: link_request.user_id,
           card_id: user_card_id).exists?(conditions = :none)
          flash[:notice] = "Links already exist!"
          return
        end

        # If all the tests were passed, the users exchange their cards:
        @link1 = Link.new(user_id: user_id, card_id: Card.find_by(user_id: 
          link_request.user_id).id , lat: @link_request1.lat,lng: @link_request1.lng, 
            meeting_date: Time.now) 

        @link2 = Link.new(user_id: link_request.user_id, card_id: user_card_id, lat: link_request.lat,
          lng: link_request.lng, meeting_date: Time.now)

        if @link1.save && @link2.save
          @link_request1.link_created = true
          @link_request1.save
          link_request.link_created = true
          link_request.save

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

  # Verify status of current link request of current user.
  # GET request: /users/:id/verifylinkcreation/
  def verifylinkcreation
    @link_request_check = LinkRequest.where(user_id: params[:id]).order("created_at ASC").last 
    @status = ""

    if @link_request_check.link_created == true
      @status = "success"
  
    elsif @link_request_check.link_created == false && (Time.now.utc - @link_request_check.created_at.utc) <= 15.seconds
      @status = "pending"

    elsif @link_request_check.link_created == false && (Time.now.utc - @link_request_check.created_at.utc) > 15.seconds
      @status = "error"
    end
    
    respond_to do |format|
      format.json {render json: {status: @status}}
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

    def link_request_params
      params.require(:link_request).permit(:card_id, :lat, :lng)
    end

    # Since distance computed is short, assume Earth is flat and that the degrees in the
    # distance between point 1 and point 2 are actually all equal to the same length in 
    # meters. We compute the distance in meters between two points using the Pythagorean Theorem. 
    """ 
    Parameters:
      lat1, lng2, lat2, lng2 are the GPS coordinates in degrees of 
      respectively point 1 and point 2, i.e. respectively user 1 and user 2.
    Return:
      Distance in meters between two points, given GPS accuracy is between 3 to 15 meters 
      in good conditions (i.e. clear view of sky). 
    """
    def shortDistance (lat1_degrees, lng1_degrees, lat2_degrees, lng2_degrees)

      # Compute the convertors of latitude degrees and longitude degrees to meters for
      # each GPS point. As a parameter, take the average of the latitudes of the two points.
      # Note: given the purpose of the app, this assumption is valid since we only want to 
      # be very accurate when the latitudes of the two points are extremely close to each other.
      # Also, the convertors are computed using latitude in RADIANS, not DEGREES.
      lat_convertor, lng_convertor = convertDegreesToMeters((lat1_degrees + lat2_degrees)/2 * Math::PI / 180)

      # Compute longitudinal and latitudinal differences in degrees:
      delta_lng_degrees = lng2_degrees - lng1_degrees
      delta_lat_degrees = lat2_degrees - lat1_degrees

      # Convert longitudinal and latitudinal differences from degrees to meters:
      delta_lng_meters = delta_lng_degrees * lng_convertor
      delta_lat_meters = delta_lat_degrees * lat_convertor

      # Compute distance in meters:
      distance_meters = Math.sqrt((delta_lng_meters**2) + (delta_lat_meters**2))
      return distance_meters
    end

    """ 
    Parameters:
    lat = latitude in radians (NOT degrees) of a GPS point
    Return: 
    latDegLength = length in meters of a degree of latitude at latitude lat
    lngDegLength = length in meters of a degree of longitude at latitude lat

    Note: constants and formulas used from https://en.wikipedia.org/wiki/Geographic
    _coordinate_system#Expressing_latitude_and_longitude_as_linear_units 
    """
    def convertDegreesToMeters (lat_radians)
      
      latDegLength  = 111132.92 - 559.82 * Math.cos(2*lat_radians) + 1.175 * Math.cos(4*lat_radians)
                - 0.0023 * Math.cos(6*lat_radians)
      lngDegLength = (111412.84 * Math.cos(lat_radians)) + ((-93.5) * Math.cos(3*lat_radians)) 
          + (0.118 * Math.cos(5*lat_radians))
      
      # Alternative formula for longitude:
      # lngDegLength = (Math::PI/180) * 6378137 * Math.sqrt(1/(1 + (0.99664719 * Math.tan(lat))**2))
      
      return latDegLength, lngDegLength
    end
end