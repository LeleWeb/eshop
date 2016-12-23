class AddressesService < BaseService
  def get_addresses(customer)
    CommonService.response_format(ResponseCode.COMMON.OK, customer.addresses)
  end

  def get_address(address)
    CommonService.response_format(ResponseCode.COMMON.OK, address)
  end

  def create_address(customer, address_params)
    Address.transaction do
      # 处理默认地址唯一性
      if address_params[:is_default] == true
        customer.addresses.collect{|address| address.update(is_default: false)}
      end

      address = customer.addresses.create!(address_params)
    end
    CommonService.response_format(ResponseCode.COMMON.OK, address)
  end

  def update_address(address, address_params)
    Address.transaction do
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
    Address.where(customer_id: address.customer_id).first.update(is_default: true)
    address.destroy
    CommonService.response_format(ResponseCode.COMMON.OK)
  end

end