class AccountsService < BaseService
  def get_accounts
    CommonService.response_format(ResponseCode.COMMON, Account.all)
  end
end