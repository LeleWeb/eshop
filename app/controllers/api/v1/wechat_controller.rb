class Api::V1::WechatController < ApplicationController
  before_action :wechat_params, only: [:index]

  # GET /wechat
  def index
    # render html: WechatService.new.get_wechat(wechat_params)
    res = WechatService.new.get_wechat(wechat_params)
    LOG.info %Q{11111: #{res}}
    render text: res
    # redirect_to "http://www.dangxiaweb.com/"
  end

  # POST /accounts
  def create
    temp = WechatService.new.create_wechat(params)
    render xml: temp
  end

  private

  # Only allow a trusted parameter "white list" through.
  def wechat_params
    params.permit(:signature, :echostr, :timestamp, :nonce)
  end

end
