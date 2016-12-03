class CustomersService < BaseService
  def get_customers
    CommonService.response_format(ResponseCode.COMMON.OK, Customer.all)
  end

  def get_customer(customer)
    CommonService.response_format(ResponseCode.COMMON.OK, customer)
  end

  def create_customer(customer_params)
    customer = Customer.new(customer_params)

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

end