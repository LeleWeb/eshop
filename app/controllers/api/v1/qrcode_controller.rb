class Api::V1::QrcodeController < Api::V1::BaseController
  #before_action :qrcode_params, only: [:create]

  # POST /qrcode
  def create
    puts 'b'*10
    p params
    render plain: QrcodeService.new.create_qrcode#, content_type: "image/jpg"
  end

  private

  # Only allow a trusted parameter "white list" through.
  def qrcode_params
    puts 'zw'*10
    p params
    params#.permit()
  end
end
