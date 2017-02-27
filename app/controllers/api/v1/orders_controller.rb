class Api::V1::OrdersController < Api::V1::BaseController
  before_action :set_order, only: [:show, :update, :destroy, :print]

  # GET /accounts
  def index
    render json: OrdersService.new.get_orders(set_query_params)
  end

  # GET /accounts/1
  def show
    authorize @order
    render json: OrdersService.new.get_order(@order)
  end

  # POST /accounts
  def create
    render json: OrdersService.new.create_order(order_params)
  end

  # # PATCH/PUT /accounts/1
  # def update
  #   authorize @order
  #   render json: OrdersService.new.update_order(@order, order_params)
  # end

  # DELETE /accounts/1
  def destroy
    authorize @order
    render json: OrdersService.new.destory_order(@order)
  end

  def print
    render json: OrdersService.new.print_order(@order)
  end

  private
  def set_query_params
    params.permit(:status,
                  :buyer_type,
                  :buyer_id,
                  :begin_time,
                  :end_time,
                  :page,
                  :per_page)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.find_by(id: params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def order_params
    params.require(:order).permit(:total_price,
                                  :buyer_id,
                                  :buyer_type,
                                  :address_id,
                                  :shopping_cart_ids => [])
  end
end
