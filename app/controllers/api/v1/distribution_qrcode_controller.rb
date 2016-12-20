class Api::V1::DistributionQrcodeController < Api::V1::BaseController
  #before_action :distribution_qrcode_params, only: [:create]
  before_action :set_product, only: [:create]

  # 基于草料二维码实现产品分销二维码功能 http://cli.im/
  def create
    render json: DistributionQrcodeService.new.create_qrcode(@product)
    # render plain: DistributionQrcodeService.new.create_qrcode, content_type: "image/jpg"
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  # Only allow a trusted parameter "white list" through.
  # def distribution_qrcode_params
  #   params#.permit()
  # end
end
