class SessionService < BaseService
  def login(login_params)
    account = Account.find_by(mobile_number: login_params[:username])
    if account && account.authenticate(login_params[:password])
      CommonService.response_format(ResponseCode.COMMON.OK, account.as_json.extract!('id', 'mobile_number', 'authentication_token'))
    else
      CommonService.response_format(ResponseCode.COMMON.FAILED)
    end
  end

  def logout
    CommonService.response_format(ResponseCode.COMMON.OK)
  end

end