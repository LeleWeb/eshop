class AddressesService < BaseService
  def get_addresses(query_params)
    if (customer = Customer.find_by(id: query_params["customer_id"])).blank?
      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "ERROR: customer:#{customer.inspect} is blank!")
    end
    CommonService.response_format(ResponseCode.COMMON.OK, customer.addresses)
  end

  def get_address(address)
    CommonService.response_format(ResponseCode.COMMON.OK, address)
  end

  def create_address(address_params)
    # 参数合法性检查
    if address_params.blank?
      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "ERROR: address_params:#{address_params.inspect} is blank!")
    end

    Address.transaction do
      customer_id = address_params.extract!("customer_id")["customer_id"]
      if (customer = Customer.find_by(id: customer_id)).blank?
        return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                             "ERROR: customer:#{customer.inspect} is blank!")
      end

      # 处理默认地址唯一性
      if address_params[:is_default] == true
        customer.addresses.collect{|address| address.update(is_default: false)}
      end

      address = customer.addresses.create!(address_params)
      CommonService.response_format(ResponseCode.COMMON.OK, address)
    end
  end

  def update_address(address, address_params)
    # 参数合法性检查
    if address.blank? || address_params.blank?
      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "ERROR: address_params:#{address_params.inspect} is blank!")
    end

    Address.transaction do
      # 不能修改所属用户，过滤掉customer外键。
      address_params.extract!("customer_id")

      # 处理默认地址唯一性
      if address_params[:is_default] == true
        Address.where(customer_id: address.customer_id).collect{|address| address.update(is_default: false)}
      end

      if address.update!(address_params)
        CommonService.response_format(ResponseCode.COMMON.OK, address)
      else
        ResponseCode.COMMON.FAILED['message'] = address.errors
        CommonService.response_format(ResponseCode.COMMON.FAILED)
      end
    end
  end

  def destory_address(address)
    if !address.nil?
      address.destroy
    end
    CommonService.response_format(ResponseCode.COMMON.OK)
  end

end