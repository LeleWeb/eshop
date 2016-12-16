class Api::V1::WxPageAuthorizationController < ApplicationController
  before_action :set_query_params, only: [:index]

  # GET api/v1/wx_page_authorization
  def index
    # 公众号网页授权后重定向的回调链接地址
    account = WechatService.get_wx_page_authorization_userinfo(@query_params)
    redirect_to "http://www.yiyunma.com" + "?id=#{account.id}&token=#{account.authentication_token}"
  end

  private

  # Only allow a trusted parameter "white list" through.
  def set_query_params
    @query_params = params.permit(:code, :state)
  end
end
