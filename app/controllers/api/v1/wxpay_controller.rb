class Api::V1::WxpayController < Api::V1::BaseController
  before_action :wxpay_params, only: [:create]

  # 微信支付结果通用通知接受接口
  def create
    render json: WxpayService.new.create_notify(wxpay_params)
  end

  private

  # Only allow a trusted parameter "white list" through.
  def wxpay_params
    params[:xml]
  end
end
