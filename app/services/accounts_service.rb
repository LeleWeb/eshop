class AccountsService < BaseService
  def get_accounts
    Account.all
  end
end