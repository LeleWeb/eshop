class SessionService < BaseService
  def login(login_params)
    account = Account.find_by(mobile_number: login_params[:username])
    if account && account.authenticate(login_params[:password])
      # 登陆成功，重置Token.
      account.reset_auth_token!

      CommonService.response_format(ResponseCode.COMMON.OK, AccountsService.get_account_data(account))
    else
      CommonService.response_format(ResponseCode.COMMON.FAILED)
    end
  end

  def logout(current_user)
    current_user.destory_auth_token!
    CommonService.response_format(ResponseCode.COMMON.OK)
  end

end