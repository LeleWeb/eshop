class Api::V1::WechatController < Api::V1::BaseController
  before_action :wechat_params, only: [:index]

  # GET /wechat
  def index
    # p '@'*10
    # p params
    # p wechat_params["echostr"]
    # puts wechat_params["echostr"].class
    render plain: "108950072435990525"#wechat_params["echostr"] #WechatService.new.get_wechat(wechat_params)
  end

  private

  # Only allow a trusted parameter "white list" through.
  def wechat_params
    params.permit(:signature, :echostr, :timestamp, :nonce)
  end

end
