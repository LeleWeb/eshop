class BackAccountsService < BaseService
  def create_back_account(customer, back_account_params)
    back_account = customer.back_accounts.create(back_account_params)
    CommonService.response_format(ResponseCode.COMMON.OK, back_account)
  end

end