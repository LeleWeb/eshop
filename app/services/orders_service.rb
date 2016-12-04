class OrdersService < BaseService
  def get_orders
    CommonService.response_format(ResponseCode.COMMON.OK, Order.all)
  end

  def get_order(order)
    CommonService.response_format(ResponseCode.COMMON.OK, order)
  end

  def create_product(product, buyer, seller, order_params)
    order = buyer.orders.create(order_params)
    order.product = product
    seller.orders << order

    CommonService.response_format(ResponseCode.COMMON.OK, order)

    # if product.save
    #   CommonService.response_format(ResponseCode.COMMON.OK, product)
    # else
    #   ResponseCode.COMMON.FAILED.message = product.errors
    #   CommonService.response_format(ResponseCode.COMMON.FAILED)
    # end
  end

  def update_product(product, product_params)
    if product.update(product_params)
      CommonService.response_format(ResponseCode.COMMON.OK, product)
    else
      ResponseCode.COMMON.FAILED['message'] = product.errors
      CommonService.response_format(ResponseCode.COMMON.FAILED)
    end
  end

  def destory_product(product)
    product.destroy
    CommonService.response_format(ResponseCode.COMMON.OK)
  end

end