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
    p __FILE__,__LINE__,%Q{ method: create_address
                            params: #{address_params.inspect} }
    # address = nil
    # customer = nil

    # 参数合法性检查
    if address_params.blank?
      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "ERROR: address_params:#{address_params.inspect} is blank!")
    end

    begin
      # 查询对应的用户
      begin
        p '1'*10,address_params,address_params.extract!("customer_id"),address_params.extract!("customer_id")["customer_id"]
        customer = Customer.find(address_params.extract!("customer_id")["customer_id"])
      rescue Exception => e
        # TODO 查询用户失败，打印对应log
        puts "Error: customer is nil! Details: #{e.message}"

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
          puts "Error: set address default failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # 创建用户收货地址
        begin
          address = customer.addresses.create!(address_params)
        rescue Exception => e
          # TODO 创建用户收货地址失败，打印对应log
          puts "Error: create address failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

      end
    rescue Exception => e
      # TODO 打印log
      puts "Error: 删除限时抢购商品失败! Details: #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED, "Error: 创建用户收货地址失败!")
    end

    CommonService.response_format(ResponseCode.COMMON.OK, address)

    # Address.transaction do
    #   customer_id = address_params.extract!("customer_id")["customer_id"]
    #   if (customer = Customer.find_by(id: customer_id)).blank?
    #     return CommonService.response_format(ResponseCode.COMMON.FAILED,
    #                                          "ERROR: customer:#{customer.inspect} is blank!")
    #   end
    #
    #   # 处理默认地址唯一性
    #   if address_params[:is_default] == true
    #     customer.addresses.collect{|address| address.update(is_default: false)}
    #   end
    #
    #   address = customer.addresses.create!(address_params)
    #   CommonService.response_format(ResponseCode.COMMON.OK, address)
    # end
  end

  def update_address(address, address_params)
    # 参数合法性检查
    if address.blank? || address_params.blank?
      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "ERROR: address_params:#{address_params.inspect} is blank!")
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
          puts "Error: set address default failed! Details: #{e.backtrace.inspect} #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # 修改用户收货地址
        begin
          address.update!(address_params)
        rescue Exception => e
          # TODO 修改用户收货地址失败，打印对应log
          puts "Error: update address failed! Details: #{e.backtrace.inspect} #{e.message}"

          # 继续向上层抛出异常
          raise e
        end
      end
    rescue Exception => e
      # TODO 打印log
      puts "Error: 修改用户收货地址失败! Details: #{e.backtrace.inspect} #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED, "Error: 修改用户收货地址失败!")
    end

    CommonService.response_format(ResponseCode.COMMON.OK, address)

    # Address.transaction do
    #   # 不能修改所属用户，过滤掉customer外键。
    #   address_params.extract!("customer_id")
    #
    #   # 处理默认地址唯一性
    #   if address_params[:is_default] == true
    #     Address.where(customer_id: address.customer_id).collect{|address| address.update(is_default: false)}
    #   end
    #
    #   if address.update!(address_params)
    #     CommonService.response_format(ResponseCode.COMMON.OK, address)
    #   else
    #     ResponseCode.COMMON.FAILED['message'] = address.errors
    #     CommonService.response_format(ResponseCode.COMMON.FAILED)
    #   end
    # end
  end

  def destory_address(address)
    if !address.nil?
      address.destroy
    end
    CommonService.response_format(ResponseCode.COMMON.OK)
  end

end