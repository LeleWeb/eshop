class Api::V1::WxPageAuthorizationController < ApplicationController
  before_action :set_query_params, only: [:index]

  # GET api/v1/wx_page_authorization
  def index
    p '@'*10
    p params
    #render html: WechatService.new.get_wechat(wechat_params)
  end

  private

  # Only allow a trusted parameter "white list" through.
  def set_query_params
    @query_params = params.permit(:code, :state)
  end
end
