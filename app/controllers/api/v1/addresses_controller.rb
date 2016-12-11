class Api::V1::AddressesController < Api::V1::BaseController
  efore_action :set_address, only: [:show, :update, :destroy]

# GET /addresses
  def index
    render json: AddressesService.new.get_addresses
  end

# GET /addresses/1
  def show
    authorize @address
    render json: AddresssesService.new.get_address(@address)
  end

# POST /api/v1/addresses
  def create
    render json: AddressesService.new.create_address(address_params)
  end

# PATCH/PUT /addresses/1
  def update
    authorize @address
    render json: AddressesService.new.update_address(@address, address_params)
  end

# DELETE /categories /1
  def destroy
    authorize @category
    render json: AddressesService.new.destory_address(@address)
  end

  private
# Use callbacks to share common setup or constraints between actions.
  def set_address
    @address = Address.find(params[:id])
  end

# Only allow a trusted parameter "white list" through.
  def address_params
    params.require(:address).permit(:name, :type, :parent_id)
  end

end
