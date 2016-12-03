class Api::V1::StoresController < Api::V1::BaseController
  before_action :set_store, only: [:show, :update, :destroy]

  # GET /accounts
  def index
    render json: CustomersService.new.get_stores
  end

  # GET /accounts/1
  def show
    authorize @store
    render json: CustomersService.new.get_store(@store)
  end

  # POST /accounts
  def create
    render json: CustomersService.new.create_store(@account, store_params)
  end

  # PATCH/PUT /accounts/1
  def update
    authorize @store
    render json: CustomersService.new.update_store(@store, store_params)
  end

  # DELETE /accounts/1
  def destroy
    authorize @store
    render json: CustomersService.new.destory_store(@store)
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_store
    @account = Account.find(params[:account_id])
    @store = Store.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def store_params
    params.require(:store).permit(:name, :description, :property, :address,
                                  :mobile_number, :remark)
  end
end
