class Api::V1::QrcodeController < Api::V1::BaseController
  before_action :qrcode_params, only: [:create]

  # POST /qrcode
  def create
    render json: QrcodeService.new.create_qrcode
  end

  private

  # Only allow a trusted parameter "white list" through.
  def qrcode_params
    params.permit()
  end
end
