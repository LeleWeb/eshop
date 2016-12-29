class BankAccountsService < BaseService
  def create_bank_account(customer, bank_account_params)
    bank_account = customer.bank_accounts.create(bank_account_params)
    CommonService.response_format(ResponseCode.COMMON.OK, bank_account)
  end

end