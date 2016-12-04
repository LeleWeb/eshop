class CartsService < BaseService
  def get_carts
    CommonService.response_format(ResponseCode.COMMON.OK, ShoppingCart.all)
  end

  def get_cart(cart)
    CommonService.response_format(ResponseCode.COMMON.OK, cart)
  end

  def create_cart(owner, product, cart_params)
    cart = owner.shopping_carts.create(cart_params)
    cart.product = product
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

end