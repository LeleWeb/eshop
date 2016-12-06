class Api::V1::OrdersController < Api::V1::BaseController
  before_action :set_order, only: [:show, :update, :destroy]
  before_action :set_buyer, only: [:create]
  before_action :set_seller, only: [:create]
  before_action :set_product, only: [:create]

  # GET /accounts
  def index
    render json: OrdersService.new.get_orders
  end

  # GET /accounts/1
  def show
    authorize @order
    render json: OrdersService.new.get_order(@order)
  end

  # POST /accounts
  def create
    render json: OrdersService.new.create_order(@product, @buyer, @seller, order_params)
  end

  # PATCH/PUT /accounts/1
  def update
    authorize @order
    render json: OrdersService.new.update_order(@order, order_params)
  end

  # DELETE /accounts/1
  def destroy
    authorize @order
    render json: OrdersService.new.destory_order(@order)
  end

  private
  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_buyer
    @buyer = eval(params[:buyer_type]).find(params[:buyer_id])
  end

  def set_seller
    @seller = eval(params[:seller_type]).find(params[:seller_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def order_params
    params.require(:order).permit(:unit_price, :amount, :status,
                                  :total_price, :estimate, :remark)
  end
end
