class Api::V1::WxPageAuthorizationController < ApplicationController
  before_action :set_query_params, only: [:index]

  # GET api/v1/wx_page_authorization
  def index
    # 公众号网页授权后重定向的回调链接地址
    res = WechatService.get_wx_page_authorization_userinfo(@query_params)
    p 'O'*10,"http://www.yiyunma.com/#/home" +  "?id=#{res["account_id"]}&parent_id=#{res["parent_account_id"]}"
    redirect_to "http://www.yiyunma.com/#/home" +  "?id=#{res["account_id"]}&parent_id=#{res["parent_account_id"]}"
  end

  private

  # Only allow a trusted parameter "white list" through.
  def set_query_params
    @query_params = params.permit(:code, :state)
  end
end
