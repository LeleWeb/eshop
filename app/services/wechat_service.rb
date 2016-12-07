class WechatService < BaseService
  def get_wechat(wechat_params)
    wechat_params["echostr"]
    # CommonService.response_format(ResponseCode.COMMON.OK)
  end

end