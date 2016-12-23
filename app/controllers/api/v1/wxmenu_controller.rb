class Api::V1::WxmenuController < Api::V1::BaseController
  before_action :wxmenu_params, only: [:create]
  skip_before_action :authenticate_user!

  # 微信支付结果通用通知接受接口
  def create
    p 'b'*10
    p params
    render json: WxmenuService.new.create_wxmenu(wxmenu_params)
  end

  private

  # Only allow a trusted parameter "white list" through.
  def wxmenu_params
    params
  end
end
