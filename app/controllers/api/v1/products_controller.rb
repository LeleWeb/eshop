class Api::V1::ProductsController < Api::V1::BaseController
  before_action :set_product, only: [:show, :update, :destroy]
  before_action :set_account
  before_action :set_store

  # GET /accounts
  def index
    render json: ProductsService.new.get_products(@store, query_params)
  end

  # GET /accounts/1
  def show
    authorize @product
    render json: ProductsService.new.get_product(@product, query_params)
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
    render json: ProductsService.new.destroy_product(@product, destroy_params)
  end

  private

  def query_params
    params.permit(:category,
                  :property,
                  :customer,
                  :type,
                  :page,
                  :per_page,
                  :search)
  end

  def set_account
    @account = Account.find(params[:account_id])
  end

  def set_store
    @store = Store.find(params[:store_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def product_params
    params.require(:product).permit(:name,
                                    :description,
                                    :stock,
                                    :status,
                                    :property,
                                    :category_id,
                                    :remark,
                                    :prices => [:id,:price,:real_price,:unit,:is_default,:display_quantity,:display_unit],
                                    :compute_strategies => [:classify,:average_quantity,:average_unit,:remark],
                                    :group_buying => [:target_amount, :begin_time, :end_time, :limit_min, :limit_max])
  end

  def destroy_params
    params[:products]
  end

end

