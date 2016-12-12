class Api::V1::WechatController < ApplicationController
  before_action :wechat_params, only: [:index]

  # GET /wechat
  def index
    render html: WechatService.new.get_wechat(wechat_params)
  end

  # POST /accounts
  def create
    p '@@@@1'
    p params.inspect
    render json: WechatService.new.create_wechat(params)
  end

  private

  # Only allow a trusted parameter "white list" through.
  def wechat_params
    params.permit(:signature, :echostr, :timestamp, :nonce)
  end

end
