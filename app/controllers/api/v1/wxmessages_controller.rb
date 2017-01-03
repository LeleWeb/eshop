class Api::V1::WxmessagesController < Api::V1::BaseController
  skip_before_action :authenticate_user!


end
