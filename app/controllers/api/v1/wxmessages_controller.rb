class Api::V1::WxmessagesController < Api::V1::BaseController
  # before_action :wxmessages_params, only: [:create]
  skip_before_action :authenticate_user!

  # 微信支付结果通用通知接受接口
  def create
    p '9'*10,params
    temp = WxmessagesService.new.wxmessages_management(params["xml"])
    render xml: temp
  end

  # private
  #
  # # Only allow a trusted parameter "white list" through.
  # def wxmessages_params
  #   params.require(:xml).permit(:ToUserName, :FromUserName, :CreateTime, :MsgType, :Event)
  # end

end
