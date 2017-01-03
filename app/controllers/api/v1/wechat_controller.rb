class Api::V1::WechatController < ApplicationController
  before_action :wechat_params, only: [:index]

  # GET /wechat
  def index
    # render html: WechatService.new.get_wechat(wechat_params)
    WechatService.new.get_wechat(wechat_params)
    redirect_to "http://www.yiyunma.com/"
  end

  # POST /accounts
  def create
    temp = WechatService.new.create_wechat(params)
    p '9'*10,temp
    render xml: temp
  end

  private

  # Only allow a trusted parameter "white list" through.
  def wechat_params
    params.permit(:signature, :echostr, :timestamp, :nonce)
  end

end
