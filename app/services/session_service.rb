class SessionService < BaseService
  def login(login_params)
    account = Account.find_by(mobile_number: login_params[:mobile_number])
    if account && account.authenticate(login_params[:password])
      self.current_user = account
      CommonService.response_format(ResponseCode.COMMON.OK, account.to_json.extract!('id', 'mobile_number', 'authentication_token'))
    else
      CommonService.response_format(ResponseCode.COMMON.FAILED)
    end
  end

  def logout
    CommonService.response_format(ResponseCode.COMMON.OK, sid)
  end

end