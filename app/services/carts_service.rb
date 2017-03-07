class CartsService < BaseService
  def get_carts(query_params)
    puts __FILE__,__LINE__,__method__,%Q{params:
                                         query_params: #{query_params.inspect} }

    carts = ShoppingCart.where(is_deleted: false, property: Settings.CART_OR_ITEM.PROPERTY.CART_ITEM)
    total_count = nil

    # 查询指定消费者的所有购物车项
    if !query_params[:owner_type].blank? && !query_params[:owner_id].blank?
      carts = carts.where(owner_type: query_params[:owner_type], owner_id: query_params[:owner_id])
    end

    # 如果存在分页参数,按照分页返回结果.
    if !query_params[:page].blank? && !query_params[:per_page].blank?
      carts = eval(carts.nil? ? "Cart" : "carts").
              page(query_params[:page]).
              per(query_params[:per_page])
      total_count = carts.total_count
    else
      total_count = carts.size
    end

    CommonService.response_format(ResponseCode.COMMON.OK, CartsService.get_carts(carts, total_count))
  end

  def get_cart(cart)
    puts __FILE__,__LINE__,__method__,%Q{params:
                                         cart: #{cart.inspect} }

    CommonService.response_format(ResponseCode.COMMON.OK, CartsService.get_cart(cart))
  end

  def create_cart(cart_params)
    puts __FILE__,__LINE__,__method__,%Q{params:
                                         cart_params: #{cart_params.inspect} }

    cart = nil

    # 参数合法性检查
    if cart_params.blank?
      # TODO 打印log
      puts "Error: file: #{__FILE__} line:#{__LINE__} cart_params: #{cart_params} is blank!"
      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "Error: file: #{__FILE__} line:#{__LINE__} cart_params:#{cart_params} is blank!")
    end

    # 解析购物车所属对象
    begin
      owner = eval(cart_params[:owner_type]).find(cart_params[:owner_id])
    rescue Exception => e
      # TODO 解析购物车所属对象失败，打印对应log
      puts "Error: file: #{__FILE__} line:#{__LINE__} find cart owner failed! Details: #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "Error: file: #{__FILE__} line:#{__LINE__} owner_type: #{cart_params[:owner_type]} or owner_id:#{cart_params[:owner_id]} is blank!")
    end

    # 解析购物车关联商品
    begin
      product = Product.find(cart_params["product_id"])
    rescue Exception => e
      # TODO 解析购物车关联商品失败，打印对应log
      puts "Error: file: #{__FILE__} line:#{__LINE__} find cart product failed! Details: #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "Error: file: #{__FILE__} line:#{__LINE__} product_id: #{cart_params["product_id"]} is blank!")
    end

    # 解析购物车关联商品的价格
    begin
      price = Price.find(cart_params["price_id"])
    rescue Exception => e
      # TODO 解析购物车关联商品的价格失败，打印对应log
      puts "Error: file: #{__FILE__} line:#{__LINE__} find cart product price failed! Details: #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "Error: file: #{__FILE__} line:#{__LINE__} price_id: #{cart_params["price_id"]} is blank!")
    end

    begin
      ShoppingCart.transaction do
        # 解析是否是多商品购物车项
        if !cart_params["subitems"].blank?
          # 对于多商品购物车项，由于复杂性目前先不判断重复项，直接新建。
          begin
            subitems = cart_params.extract!("subitems")["subitems"]
            parent_cart = owner.shopping_carts.create!(cart_params)
            subitems.each do |subitem|
              # 对于自关联的购物车项的非根节点记录，都不用指定owner，减少根据customer查询购物车时的冗余数据。
              subitem.extract!("owner_type", "owner_id")
              parent_cart.subitems.create!(subitem)
            end
            cart = parent_cart
          rescue Exception => e
            # TODO 创建多商品购物车项失败，打印对应log
            puts "Error: file: #{__FILE__} line:#{__LINE__} create multi products cart failed! Details: #{e.message}"

            # 继续向上层抛出异常
            raise e
          end
        else
          # 购物车纪录建立
          begin
            if cart = owner.shopping_carts.where(product_id: product.id,
                                                 price_id: price.id,
                                                 property: Settings.CART_OR_ITEM.PROPERTY.CART_ITEM,
                                                 is_deleted: false).first
              # 如果是购物车加入同相同商品，相同价格的物品，则只修改数量。
              cart.update!(amount: cart.amount + cart_params["amount"].to_i,
                          total_price: cart.total_price + cart_params["total_price"].to_f)
            else
              cart = owner.shopping_carts.create!(cart_params)
            end
          rescue Exception => e
            # TODO 创建单商品购物车项失败，打印对应log
            puts "Error: file: #{__FILE__} line:#{__LINE__} create single product cart failed! Details: #{e.message}"

            # 继续向上层抛出异常
            raise e
          end
        end
      end
    rescue Exception => e
      # TODO 打印log
      puts "Error: file: #{__FILE__} line:#{__LINE__} 创建购物车失败! Details: #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED, "Error: file: #{__FILE__} line:#{__LINE__} 创建购物车失败!")
    end

    CommonService.response_format(ResponseCode.COMMON.OK, CartsService.get_cart(cart))
  end

  def update_cart(cart, cart_params)
    puts __FILE__,__LINE__,__method__,%Q{params:
                                         cart: #{cart.inspect},
                                         cart_params: #{cart_params.inspect} }

    # 参数合法性检查
    if cart_params.blank?
      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "Error: file: #{__FILE__} line:#{__LINE__} cart_params:#{cart_params} is blank!")
    end

    # 修改购物车项数量和总金额
    begin
      cart.update!(amount: cart_params["amount"], total_price: cart_params["total_price"])
    rescue Exception => e
      # TODO 修改购物车项数量和总金额失败，打印对应log
      puts "Error: file: #{__FILE__} line:#{__LINE__} update cart amount and total_price failed! Details: #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "Error: file: #{__FILE__} line:#{__LINE__} update cart amount and total_price failed! Details: #{e.message}")
    end

    CommonService.response_format(ResponseCode.COMMON.OK, CartsService.get_cart(cart))
  end

  def destroy_cart(cart)
    puts __FILE__,__LINE__,__method__,%Q{params:
                                         cart: #{cart.inspect} }

    begin
      ShoppingCart.transaction do
        # 删除购物车
        begin
          cart.update(is_deleted: true, deleted_at: Time.now)
        rescue Exception => e
          # TODO 删除购物车失败，打印对应log
          puts "Error: file: #{__FILE__} line:#{__LINE__} destroy cart failed! Details: #{e.message}"

          return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                               "Error: file: #{__FILE__} line:#{__LINE__} destroy cart failed! Details: #{e.message}")
        end
      end
    rescue Exception => e
      # TODO 打印log
      puts "Error: file: #{__FILE__} line:#{__LINE__} 删除购物车失败! Details: #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "Error: file: #{__FILE__} line:#{__LINE__} 删除购物车失败! Details: #{e.message}")
    end

    CommonService.response_format(ResponseCode.COMMON.OK)
  end

  # private

  def get_cart_data(cart)
    cart.as_json.merge(:product => ProductsService.find_product_data(cart.product))
  end

  # 根据订单删除购物车中已经生成订单的购物车商品
  def self.delete_shopping_cart(customer, order)
    order_products = order.order_details.collect{|order_detail| order_detail.product_id}
    customer.shopping_carts.each do |shopping_cart|
      if order_products.include?(shopping_cart.product_id)
        shopping_cart.destroy
      end
    end
  end

  def self.get_cart(cart)
    # 格式化返回数据
    cart.as_json.merge("product" => ProductsService.find_product_data(cart.product),
                       "price" => cart.price,
                       "subitems" => self.get_carts_no_count(cart.subitems))
  end

  # 批量返回时携带记录总数，用于分页显示调用。
  def self.get_carts(carts, total_count)
    data = carts.collect{|cart| self.get_cart(cart)}
    {"total_count" => total_count.nil? ? carts.length : total_count, "carts" => data}
  end

  # 批量返回时无记录总数，用于正常请求数据调用。
  def self.get_carts_no_count(carts)
    carts.collect{|cart| self.get_cart(cart)}
  end

  def self.get_customer_carts(customer_id)
    carts = []

    if (customer = Customer.find_by(id: customer_id)).nil?
      return carts
    end

    carts = customer.shopping_carts.where(is_deleted: false,
                                          property: Settings.CART_OR_ITEM.PROPERTY.CART_ITEM)
    self.get_carts(carts, carts.size)
  end

end