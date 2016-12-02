class CustomersService < BaseService
  def get_customers
    CommonService.response_format(ResponseCode.COMMON.OK, Customer.all)
  end

  def get_customer(customer)
    CommonService.response_format(ResponseCode.COMMON.OK, customer)
  end

  def create_customer(customer_params)
    customer = Customer.create!(:name => customer_params[:name])

    if category_params[:type] == 'child'
      parent_category = Category.find(category_params[:parent_id])
      category.move_to_child_of(parent_category)
    end

    CommonService.response_format(ResponseCode.COMMON.OK, category)
  end

  def update_customer(customer, customer_params)
    if customer.update(account_params)
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