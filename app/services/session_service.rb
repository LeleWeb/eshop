class SessionService < BaseService
  def login(login_params)
    account = Account.find_by(mobile_number: login_params[:username])
    if account && account.authenticate(login_params[:password])
      # 登陆成功，重置Token.
      account.reset_auth_token!

      CommonService.response_format(ResponseCode.COMMON.OK, get_account_data(account))
    else
      CommonService.response_format(ResponseCode.COMMON.FAILED)
    end
  end

  def logout(current_user)
    current_user.destory_auth_token!
    CommonService.response_format(ResponseCode.COMMON.OK)
  end

  # private

  def get_account_data(account)
    data = {}
    # account data
    data[:account] = account.as_json.extract!('id', 'mobile_number', 'authentication_token')

    # customer
    data[:customer] = account.customer

    # stores
    # data[:store] = account.store

    data
  end

end