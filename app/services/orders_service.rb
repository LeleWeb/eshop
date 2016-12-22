class OrdersService < BaseService
  def get_orders(buyer)
    CommonService.response_format(ResponseCode.COMMON.OK, OrdersService.get_order_datas(buyer.orders))
  end

  def get_order(order)
    CommonService.response_format(ResponseCode.COMMON.OK, OrdersService.get_order_data(order))
  end

  def create_order(buyer, order_params, details)
    # 生成本系统订单
    order_params[:order_number] = SecureRandom.hex
    order_params[:status] = Settings.ORDER.STATUS.PREPAY
    order_params[:pay_away] = 1
    order_params[:time_start] = Time.now.strftime("%Y%m%d%H%M%S")
    order_params[:time_expire] = (Time.now + Settings.ORDER.EXPIRE_TIME.to_i).strftime("%Y%m%d%H%M%S")
    order = buyer.orders.create(order_params)
    # 暂时设置实际支付订单为订单总额
    order.update(pay_price: order.total_price)

    # 生成对应的订单详情项
    details.each do |detail|
      order.order_details.create(detail.permit(:product_id, :quantity, :price))
    end

    # 调用微信统一接口,生成预付订单.
    res = WechatService.create_unifiedorder(order)

    CommonService.response_format(ResponseCode.COMMON.OK, {"order" => order, "prepay_data" => res})
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

  def self.get_order_data(order)
    order.to_hash.merge("order_details" => order.order_details)
  end

  def self.get_order_datas(orders)
    data = []
    orders.each do |order|
      data << self.get_order_data(order)
    end
    data
  end

end