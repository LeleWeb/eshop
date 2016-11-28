class SessionService < BaseService
  def login(login_params)
    CommonService.response_format(ResponseCode.COMMON.OK)
  end

  def logout
    CommonService.response_format(ResponseCode.COMMON.OK)
  end

end