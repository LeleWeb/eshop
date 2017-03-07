class Api::V1::CartsController < Api::V1::BaseController
  before_action :set_cart, only: [:show, :update, :destroy]

  # GET /accounts
  def index
    render json: CartsService.new.get_carts(query_params)
  end

  # GET /accounts/1
  def show
    authorize @cart
    render json: CartsService.new.get_cart(@cart)
  end

  # POST /accounts
  def create
    render json: CartsService.new.create_cart(cart_params)
  end

  # PATCH/PUT /accounts/1
  def update
    authorize @cart
    render json: CartsService.new.update_cart(@cart, cart_params)
  end

  # DELETE /accounts/1
  def destroy
    authorize @cart
    render json: CartsService.new.destroy_cart(@cart)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_cart
    @cart = ShoppingCart.find_by(id: params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def cart_params
    params.require(:cart).permit( :product_id,
                                  :price_id,
                                  :amount,
                                  :total_price,
                                  :owner_id,
                                  :owner_type,
                                  :remark,
                                  :property,
                                  :subitems => [:product_id,
                                                :price_id,
                                                :amount,
                                                :total_price,
                                                :owner_id,
                                                :owner_type,
                                                :remark,
                                                :property,])
  end

  def query_params
    params.permit(:page,
                  :per_page,
                  :owner_type,
                  :owner_id)
  end

end
