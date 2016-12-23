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

  def create_cart(owner, product, cart_params)
    if cart = owner.shopping_carts.where(product_id: product.id).first
      # 购物车加入同一件商品，只修改数量
      cart.update(amount: cart.amount + 1)
    else
      cart = owner.shopping_carts.create(cart_params)
      cart.update(product_id: product.id)
    end

    CommonService.response_format(ResponseCode.COMMON.OK, {:cart => cart,
                                                           :cart_item_amount => owner.shopping_carts(force_reload = true).length})
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
        shopping_cart.destory
      end
    end
  end

end