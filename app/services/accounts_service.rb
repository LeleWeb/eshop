class AccountsService < BaseService
  def get_accounts
    CommonService.response_format(ResponseCode.COMMON.OK, Account.all)
  end

  def get_account(account)
    CommonService.response_format(ResponseCode.COMMON.OK, account)
  end

  def create_account(account_params)
    account = Account.new(account_params)

    if account.save
      CommonService.response_format(ResponseCode.COMMON.OK, account)
    else
      ResponseCode.COMMON.FAILED.message = account.errors
      CommonService.response_format(ResponseCode.COMMON.FAILED)
    end
  end

  def update_account(account, account_params)
    if account.update(account_params)
      CommonService.response_format(ResponseCode.COMMON.OK, account)
    else
      ResponseCode.COMMON.FAILED['message'] = account.errors
      CommonService.response_format(ResponseCode.COMMON.FAILED)
    end
  end

  def destory_account(account)
    account.destroy
    CommonService.response_format(ResponseCode.COMMON.OK)
  end

end