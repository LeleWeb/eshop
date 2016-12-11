class AddressesService < BaseService
  def get_addresses
    CommonService.response_format(ResponseCode.COMMON.OK, Address.all)
  end

  def get_address(address)
    CommonService.response_format(ResponseCode.COMMON.OK, address)
  end

  def create_address(address_params)
    create(address_params)
    CommonService.response_format(ResponseCode.COMMON.OK,address)
  end

  def update_address(address, address_params)
    if address.update(address_params)
      CommonService.response_format(ResponseCode.COMMON.OK, address)
    else
      ResponseCode.COMMON.FAILED['message'] = address.errors
      CommonService.response_format(ResponseCode.COMMON.FAILED)
    end
  end

  def destory_address(address)
    address.destroy
    CommonService.response_format(ResponseCode.COMMON.OK)
  end


end