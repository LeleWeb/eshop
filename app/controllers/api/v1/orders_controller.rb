class Api::V1::OrdersController < Api::V1::BaseController
  before_action :set_order, only: [:show, :update, :destroy]
  before_action :set_buyer, only: [:create, :index]
  before_action :set_details, only: [:create]
  before_action :set_address, only: [:create]

  # GET /accounts
  def index
    render json: OrdersService.new.get_orders(@buyer)
  end

  # GET /accounts/1
  def show
    authorize @order
    render json: OrdersService.new.get_order(@order)
  end

  # POST /accounts
  def create
    render json: OrdersService.new.create_order(@buyer, @address, order_params, set_details)
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
  def set_address
    @address = Address.find(params[:address_id])
  end

  def set_details
    params.require(:details)
  end

  def set_buyer
    @buyer = eval(params[:buyer_type]).find(params[:buyer_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def order_params
    params.require(:order).permit(:consignee_address, :consignee_name, :consignee_phone,
                                  :total_price, :estimate, :remark)
  end
end
