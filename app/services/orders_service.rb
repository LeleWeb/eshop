class OrdersService < BaseService
  def get_orders
    CommonService.response_format(ResponseCode.COMMON.OK, Order.all)
  end

  def get_order(order)
    CommonService.response_format(ResponseCode.COMMON.OK, order)
  end

  def create_order(buyer, order_params, details)
    # 生成本系统订单
    order_params[:order_number] = UUID.new.generate
    order_params[:status] = Settings.ORDER.STATUS.PREPAY
    order_params[:pay_away] = 1
    order_params[:time_start] = Time.now.strftime("%Y%m%d%H%M%S")
    order_params[:time_expire] = (Time.now + Settings.ORDER.EXPIRE_TIME.to_i).strftime("%Y%m%d%H%M%S")
    order = buyer.orders.create(order_params)

    # 生成对应的订单详情项
    details.each do |detail|
      order.order_details.create(detail)
    end

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