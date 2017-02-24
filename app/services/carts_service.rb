class CartsService < BaseService
  def get_carts(owner)
    carts = []
    if !owner.nil?
      carts = owner.shopping_carts
    end

    CommonService.response_format(ResponseCode.COMMON.OK, get_carts_data(carts))
  end

  def get_cart(cart)
    CommonService.response_format(ResponseCode.COMMON.OK, cart)
  end

  def create_cart(cart_params)
    # 参数合法性检查
    if cart_params.blank?
      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "ERROR: cart_params:#{cart_params} is blank!")
    end

    # 解析购物车所属对象
    if (owner = eval(cart_params[:owner_type]).find_by(id: cart_params[:owner_id])).nil?
      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "ERROR: owner_type: #{cart_params[:owner_type]} or owner_id:#{cart_params[:owner_id]} is blank!")
    end

    # 解析购物车关联商品
    if (product = Product.find_by(id: cart_params["product_id"])).nil?
      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "ERROR: product_id: #{cart_params["product_id"]} is blank!")
    end

    # 解析购物车关联商品的价格
    if (price = Price.find_by(id: cart_params["price_id"])).nil?
      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "ERROR: price_id: #{cart_params["price_id"]} is blank!")
    end

    # 购物车纪录建立
    if cart = owner.shopping_carts.where(product_id: product.id, price_id: price.id).first
      # 如果是购物车加入同相同商品，相同价格的物品，则只修改数量。
      cart.update(amount: cart.amount + 1)
    else
      cart = owner.shopping_carts.create(cart_params)
    end

    CommonService.response_format(ResponseCode.COMMON.OK, CartsService.get_cart(cart))
  end

  def update_cart(cart, cart_params)
    if cart.update(cart_params)
      CommonService.response_format(ResponseCode.COMMON.OK, cart)
    else
      ResponseCode.COMMON.FAILED['message'] = cart.errors
      CommonService.response_format(ResponseCode.COMMON.FAILED)
    end
  end

  def destory_cart(cart)
    cart.destroy
    CommonService.response_format(ResponseCode.COMMON.OK)
  end

  private

  def get_carts_data(carts)
    data = []
    carts.each do |cart|
      data << get_cart_data(cart)
    end
    data
  end

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
                       "price" => cart.price)
  end

end