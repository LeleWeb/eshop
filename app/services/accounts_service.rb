class AccountsService < BaseService
  def get_accounts
    CommonService.response_format(ResponseCode.COMMON.OK, Account.all)
  end

  def get_account(id)
    CommonService.response_format(ResponseCode.COMMON.OK, Account.find(id))
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

  def update_account(id, account_params)
    p 'a'*10,id,account_params
    byebug
    account = Account.find(id)
    if account.update(account_params)
      CommonService.response_format(ResponseCode.COMMON.OK, account)
    else
      ResponseCode.COMMON.FAILED['message'] = account.errors
      CommonService.response_format(ResponseCode.COMMON.FAILED)
    end
  end

  def destroy_account(id)
    Account.find(id).destroy
    CommonService.response_format(ResponseCode.COMMON.OK)
  end

end