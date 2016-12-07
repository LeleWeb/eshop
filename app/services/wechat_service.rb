class WechatService < BaseService
  def get_wechat

    CommonService.response_format(ResponseCode.COMMON.OK)
  end

end