class WechatService < BaseService
  def get_wechat(wechat_params)
    {:echostr => wechat_params["echostr"]}
    # CommonService.response_format(ResponseCode.COMMON.OK)
  end

end