class AddressesService < BaseService
  def get_addresses
    CommonService.response_format(ResponseCode.COMMON.OK, address.root.self_and_descendants)
  end

  def get_address(address)
    CommonService.response_format(ResponseCode.COMMON.OK,  address.self_and_descendants)
  end

  def create_address(address_params)
    address = Address.create!(:name => address_params[:name])
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

  private

  def get_address_data(addresses)
    data = []
    addresses.each do |address|
      data << get_address_data(address)
    end
    data
  end

  def get_cart_data(address)
    address.as_json.merge(:product => ProductsService.find_product_data(address.product))
  end

end