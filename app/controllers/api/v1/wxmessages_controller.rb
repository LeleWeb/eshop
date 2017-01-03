class Api::V1::WxmessagesController < Api::V1::BaseController
  skip_before_action :authenticate_user!

  # 微信支付结果通用通知接受接口
  def create
    p 'a'*10,params
  end

end
