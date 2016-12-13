class OrdersService < BaseService
  def get_orders
    CommonService.response_format(ResponseCode.COMMON.OK, Order.all)
  end

  def get_order(order)
    CommonService.response_format(ResponseCode.COMMON.OK, order)
  end

  def create_order(product, buyer, seller, order_params)
    # 生成本系统订单
    order_params[:uuid] = UUID.new.generate
    order = buyer.orders.create(order_params)
    order.product = product
    seller.orders << order

    # 调用微信统一接口,生成预付订单.
    WechatService.create_unifiedorder(order)

    CommonService.response_format(ResponseCode.COMMON.OK, order)
  end

  def update_order(order, order_params)
    if order.update(order_params)
      CommonService.response_format(ResponseCode.COMMON.OK, order)
    else
      ResponseCode.COMMON.FAILED['message'] = order.errors
      CommonService.response_format(ResponseCode.COMMON.FAILED)
    end
  end

  def destory_order(order)
    order.destroy
    CommonService.response_format(ResponseCode.COMMON.OK)
  end

end