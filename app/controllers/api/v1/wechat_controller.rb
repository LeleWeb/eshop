class Api::V1::WechatController < Api::V1::BaseController
  # GET /wechat
  def index
    p '@'*10
    p params
    render json: WechatService.new.get_wechat
  end

end
