class SessionService < BaseService
  def login(login_params)
    CommonService.response_format(ResponseCode.COMMON.OK)
  end

  def logout(sid)
    CommonService.response_format(ResponseCode.COMMON.OK, sid)
  end

end