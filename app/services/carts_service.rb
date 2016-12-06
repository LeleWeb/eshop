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
    if cart = owner.shopping_carts.where(product_id: product.id)
      # 购物车加入同一件商品，只修改数量
      cart.update(amount: cart.amount + 1)
    else
      cart = owner.shopping_carts.create(cart_params)
      cart.product = product
    end

    CommonService.response_format(ResponseCode.COMMON.OK, cart)
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
    cart.as_json.merge(:product => cart.product)
  end

end