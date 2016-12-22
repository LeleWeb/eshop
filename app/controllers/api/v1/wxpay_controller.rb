class Api::V1::WxpayController < Api::V1::BaseController
  before_action :wxpay_params, only: [:create]
  skip_before_action :authenticate_user!

  # 微信支付结果通用通知接受接口
  def create
    puts 'q'*10
    p temp = WxpayService.new.create_notify(wxpay_params)
    render xml: temp
  end

  private

  # Only allow a trusted parameter "white list" through.
  def wxpay_params
    params.require[:xml].permit(:appid, :mch_id, :device_info, :nonce_str, :sign,
                                :sign_type, :result_code, :err_code, :err_code_des,
                                :openid, :is_subscribe, :trade_type, :bank_type,
                                :total_fee, :settlement_total_fee, :fee_type, :cash_fee,
                                :cash_fee_type, :coupon_fee, :coupon_count, :out_trade_no,
                                :attach, :time_end)
  end
end
