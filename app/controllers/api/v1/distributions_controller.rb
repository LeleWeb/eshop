class Api::V1::DistributionsController < Api::V1::BaseController
  before_action :set_store, only: [:create, :get_distribute_authority]
  before_action :set_customer, only: [:get_commission]

  # POST /api/v1/addresses
  def create
    render json: DistributionsService.new.create_distribution(@store, distribution_params)
  end

  def get_commission
    render json: DistributionsService.new.get_commission(@customer)
  end

  def get_distribute_authority
    render json: DistributionsService.new.get_distribute_authority(@store, distribution_params)
  end

  private
  def set_customer
    @customer = Customer.find_by(id: params[:customer_id])
  end

  def set_store
    @store = Store.find(params[:store_id])
  end

  # Only allow a trusted parameter "white list" through.
  def distribution_params
    params.require(:distribution).permit(:owner_type, :owner_id, :parent_id, :parent_type)
  end

end
