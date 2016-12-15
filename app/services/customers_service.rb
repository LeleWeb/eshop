class CustomersService < BaseService
  def get_customers
    CommonService.response_format(ResponseCode.COMMON.OK, Customer.all)
  end

  def get_customer(customer)
    CommonService.response_format(ResponseCode.COMMON.OK, customer)
  end

  def create_customer(account, customer_params)
    customer = account.build_customer(customer_params)

    if customer.save
      CommonService.response_format(ResponseCode.COMMON.OK, customer)
    else
      ResponseCode.COMMON.FAILED.message = customer.errors
      CommonService.response_format(ResponseCode.COMMON.FAILED)
    end
  end

  def update_customer(customer, customer_params)
    if customer.update(customer_params)
      CommonService.response_format(ResponseCode.COMMON.OK, customer)
    else
      ResponseCode.COMMON.FAILED['message'] = customer.errors
      CommonService.response_format(ResponseCode.COMMON.FAILED)
    end
  end

  def destory_customer(customer)
    customer.destroy
    CommonService.response_format(ResponseCode.COMMON.OK)
  end

  # 微信网页授权登录后本系统customer用户同步方法
  def self.update_customer_by_wechat(access_token)
    # 查询该用户是否第一次登录
    customer = Customer.find_by(openid: access_token["openid"])
    if customer.nil?
      account = Account.create(uuid: SecureRandom.hex)
      puts '4'*10
      p account
      # 创建customer
      customer = account.create_customer(access_token)
      puts '5'*10
      p customer
    else
      # 更新customer
      customer.update(access_token)
    end
    customer
  end

end