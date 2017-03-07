class AddressesService < BaseService
  def get_addresses(query_params)
    p __FILE__,__LINE__,__method__,%Q{params:
                                      query_params: #{query_params.inspect}}

    if (customer = Customer.find_by(id: query_params["customer_id"])).blank?
      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "Error: file: #{__FILE__} line:#{__LINE__} customer:#{customer.inspect} is blank!")
    end
    CommonService.response_format(ResponseCode.COMMON.OK, customer.addresses)
  end

  def get_address(address)
    p __FILE__,__LINE__,__method__,%Q{params:
                                      address: #{address.inspect}}

    CommonService.response_format(ResponseCode.COMMON.OK, address)
  end

  def create_address(address_params)
    p __FILE__,__LINE__,__method__,%Q{params:
                                      address_params: #{address_params.inspect}}
    address = nil

    # 参数合法性检查
    if address_params.blank?
      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "Error: file: #{__FILE__} line:#{__LINE__} address_params:#{address_params.inspect} is blank!")
    end

    begin
      # 查询对应的用户
      begin
        customer = Customer.find(address_params.extract!("customer_id")["customer_id"])
      rescue Exception => e
        # TODO 查询用户失败，打印对应log
        puts "Error: file: #{__FILE__} line:#{__LINE__} customer is nil! Details: #{e.message}"

        # 继续向上层抛出异常
        raise e
      end

      PanicBuying.transaction do
        # 处理默认地址唯一性
        begin
          if address_params[:is_default] == true
            customer.addresses.collect{|address| address.update!(is_default: false)}
          end
        rescue Exception => e
          # TODO 处理默认地址唯一性失败，打印对应log
          puts "Error: file: #{__FILE__} line:#{__LINE__} set address default failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # 创建用户收货地址
        begin
          address = customer.addresses.create!(address_params)
        rescue Exception => e
          # TODO 创建用户收货地址失败，打印对应log
          puts "Error: file: #{__FILE__} line:#{__LINE__} create address failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

      end
    rescue Exception => e
      # TODO 打印log
      puts "Error: file: #{__FILE__} line:#{__LINE__} 删除限时抢购商品失败! Details: #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED, "Error: file: #{__FILE__} line:#{__LINE__} 创建用户收货地址失败!")
    end

    CommonService.response_format(ResponseCode.COMMON.OK, address)
  end

  def update_address(address, address_params)
    p __FILE__,__LINE__,__method__,%Q{params:
                                      address: #{address.inspect},
                                      address_params: #{address_params.inspect}}

    # 参数合法性检查
    if address.blank? || address_params.blank?
      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "Error: file: #{__FILE__} line:#{__LINE__} address_params:#{address_params.inspect} is blank!")
    end

    begin
      # 不能修改所属用户，过滤掉customer外键。
      address_params.extract!("customer_id")

      PanicBuying.transaction do
        # 处理默认地址唯一性
        begin
          if address_params[:is_default] == true
            Address.where(customer_id: address.customer_id).collect{|address| address.update!(is_default: false)}
          end
        rescue Exception => e
          # TODO 处理默认地址唯一性失败，打印对应log
          puts "Error: file: #{__FILE__} line:#{__LINE__} set address default failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # 修改用户收货地址
        begin
          address.update!(address_params)
        rescue Exception => e
          # TODO 修改用户收货地址失败，打印对应log
          puts "Error: file: #{__FILE__} line:#{__LINE__} update address failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end
      end
    rescue Exception => e
      # TODO 打印log
      puts "Error: file: #{__FILE__} line:#{__LINE__} 修改用户收货地址失败! Details: #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED, "Error: file: #{__FILE__} line:#{__LINE__} 修改用户收货地址失败!")
    end

    CommonService.response_format(ResponseCode.COMMON.OK, address)
  end

  def destory_address(address)
    p __FILE__,__LINE__,__method__,%Q{params:
                                      address: #{address.inspect}}

    if !address.nil?
      address.destroy
    end
    CommonService.response_format(ResponseCode.COMMON.OK)
  end

end