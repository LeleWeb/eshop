class Api::V1::OrdersController < Api::V1::BaseController
  before_action :set_order, only: [:show, :update, :destroy]
  before_action :set_store
  before_action :set_customer
  before_action :set_product

  # GET /accounts
  def index
    render json: ProductsService.new.get_products
  end

  # GET /accounts/1
  def show
    authorize @product
    render json: ProductsService.new.get_product(@product)
  end

  # POST /accounts
  def create
    render json: ProductsService.new.create_product(@store, product_params)
  end

  # PATCH/PUT /accounts/1
  def update
    authorize @product
    render json: ProductsService.new.update_product(@product, product_params)
  end

  # DELETE /accounts/1
  def destroy
    authorize @product
    render json: ProductsService.new.destory_product(@product)
  end

  private
  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_account
    @account = Account.find(params[:account_id])
  end

  def set_store
    @store = Store.find(params[:store_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def order_params
    params.require(:product).permit(:name, :description, :detail, :stock, :price, :real_price,
                                    :status, :property, :category_id, :remark, :details)
  end
end
