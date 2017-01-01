class AccountsService < BaseService
  def get_accounts
    CommonService.response_format(ResponseCode.COMMON.OK, Account.all)
  end

  def get_account(account)
    CommonService.response_format(ResponseCode.COMMON.OK,
                                  AccountsService.get_account_data(account))
  end

  def create_account(account_params)
    CommonService.response_format(ResponseCode.COMMON.OK,
                                  AccountsService.create_system_of_account(account_params))
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

  # 获取账户下的所有关联信息
  def self.get_account_data(account)
    data = {}
    # account data
    data[:account] = account.as_json.extract!('id', 'mobile_number', 'authentication_token')

    # customer
    data[:customer] = account.customer

    # stores
    data[:store] = account.store

    data
  end

  # 创建本系统账号体系,包括：account(系统账号),customer(消费者),customer_accounts(消费者账户)
  def self.create_system_of_account(account_params, wx_access_token=nil)
    account = nil
    customer = nil
    customer_account = nil

    if account_params.nil? && !wx_access_token.blank?
      # 微信网页授权登录,自动创建账户体系.
      # 创建account,customer.
      account = Account.create(uuid: SecureRandom.hex, password: LocalConfig.DEFAULT_PASSWORD)
      customer = account.create_customer(access_token: wx_access_token)
    else
      # 网页注册，通过参数创建账户体系
      account = Account.create(account_params)
      customer = account.create_customer()
    end

    # 创建用户账户
    customer_account = customer.create_customer_account(withdraw_sum: 0.0)
    {"account" => account, "customer" => customer, "customer_account" => customer_account}
  end

end