class Api::V1::DistributionsController < Api::V1::BaseController
  before_action :set_store, only: [:create]

# POST /api/v1/addresses
  def create
    render json: DistributionsService.new.create_distribution(@store, distribution_params)
  end

  private
  def set_store
    @store = Store.find(params[:store_id])
  end

  # Only allow a trusted parameter "white list" through.
  def distribution_params
    params.require(:distribution).permit(:owner_type, :owner_id, :parent_id)
  end

end
