class UsersController < ApplicationController
  
  # On ajoute la méthode createcard dans la liste des méthodes où on set le user au début
  before_action :set_user, only: [:show, :edit, :update, :destroy, :createcard]

  # On saute une etape de securite si on appel CREATECARD en JSON
  skip_before_action :verify_authenticity_token, only: [:createcard]


  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
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
        format.json
      else
        format.json { render json: @card.errors, status: :unprocessable_entity }
      end
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
    def card_params
      params.require(:card).permit(:card_name, :first_name, :last_name, :phone_nbr, :facebook_link, 
        :linkedin_link, :email, :street, :city, :postal_code, :country, :description, :picture_url)
    end
end



# Curl de test pour le createcard :
# curl 'http://localhost:3000/users/1/createcard.json' -H 'Content-Type: application/json'  -d '{"card": {"card_name": "Business", "first_name": "Ben", "last_name": "Stirrup", "phone_nbr": "0606060606", "facebook_link": "...", "linkedin_link": "...", "email": "...", "street": "5 rue du surf", "city": "Noumea", "postal_code": ".", "coutry": "Nouvelle-Calédonie", "descrition": "blabla", "picture_url": "."} }'
