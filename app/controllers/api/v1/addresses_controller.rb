class Api::V1::AddressesController < Api::V1::BaseController
  before_action :set_address, only: [:show, :update, :destroy]
  before_action :set_customer, only: [:create, :index]

# GET /addresses
  def index
    render json: AddressesService.new.get_addresses(@customer)
  end

# GET /addresses/1
  def show
    authorize @address
    render json: AddressesService.new.get_address(@address)
  end

# POST /api/v1/addresses
  def create
    render json: AddressesService.new.create_address(@customer, address_params)
  end

# PATCH/PUT /addresses/1
  def update
    authorize @address
    render json: AddressesService.new.update_address(@address, address_params)
  end

# DELETE /addresses /1
  def destroy
    authorize @address
    render json: AddressesService.new.destory_address(@address)
  end

  private
# Use callbacks to share common setup or constraints between actions.
  def set_customer
    @customer = Customer.find(params[:customer_id])
  end

  def set_address
    @address = Address.find(params[:id])
  end

# Only allow a trusted parameter "white list" through.
  def address_params
    params.require(:address).permit(:name, :phone, :address, :is_default)
  end


end
