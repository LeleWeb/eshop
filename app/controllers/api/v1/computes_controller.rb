class Api::V1::ComputesController < Api::V1::BaseController
  # POST /api/v1/computes
  def create
    render json: ComputesService.new.create_compute(compute_params)
  end

  private
  # Only allow a trusted parameter "white list" through.
  def compute_params
    params.require(:compute).permit(:category,
                                    :params)
  end
end
