class Api::V1::CartsController < Api::V1::BaseController
  before_action :set_cart, only: [:show, :update, :destroy]
  before_action :set_owner, :set_product, only: [:index, :create]

  # GET /accounts
  def index
    render json: CartsService.new.get_carts(@owner)
  end

  # GET /accounts/1
  def show
    authorize @cart
    render json: CartsService.new.get_cart(@cart)
  end

  # POST /accounts
  def create
    render json: CartsService.new.create_cart(@owner, @product, cart_params)
  end

  # PATCH/PUT /accounts/1
  def update
    authorize @cart
    render json: CartsService.new.update_cart(@cart, cart_params)
  end

  # DELETE /accounts/1
  def destroy
    authorize @cart
    render json: CartsService.new.destory_cart(@cart)
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_owner
    @owner = eval(params[:owner_type]).find(params[:owner_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_cart
    @cart = ShoppingCart.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def cart_params
    params.require(:cart).permit(:amount, :remark)
  end
end
