class OrdersService < BaseService
  def get_orders(buyer)
    CommonService.response_format(ResponseCode.COMMON.OK, OrdersService.get_order_datas(buyer.orders))
  end

  def get_order(order)
    CommonService.response_format(ResponseCode.COMMON.OK, OrdersService.get_order_data(order))
  end

  def create_order(buyer, address, order_params, details)
    # 生成本系统订单
    order_params[:order_number] = SecureRandom.hex
    order_params[:status] = Settings.ORDER.STATUS.PREPAY
    order_params[:pay_away] = 1
    order_params[:time_start] = Time.now.strftime("%Y%m%d%H%M%S")
    order_params[:time_expire] = (Time.now + Settings.ORDER.EXPIRE_TIME.to_i).strftime("%Y%m%d%H%M%S")
    order = buyer.orders.create(order_params.merge("consignee_address" => address.detailed_address))
    # 暂时设置实际支付订单为订单总额
    order.update(pay_price: order.total_price)

    # 生成对应的订单详情项
    details.each do |detail|
      order.order_details.create(detail.permit(:product_id, :quantity, :price))
    end

    # 删除订单对应的购物车商品
    CartsService.delete_shopping_cart(buyer, order)

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
    order.as_json.merge("order_details" => order.order_details.collect{|order_detail| order_detail.as_json.merge("product" => ProductsService.find_product_data(order_detail.product))})
  end

  def self.get_order_datas(orders)
    data = []
    orders.each do |order|
      data << self.get_order_data(order)
    end
    data
  end

  # 定时刷新订单状态，已发货的订单，超过七天后自动设置为已完成方法。
  def self.update_order_status
    # 查找所有状态为已发货的订单
    orders = Order.where(status: Settings.ORDER.STATUS.DELIVERED)

    # 根据订单操作日志表读取每个订单的操作时间，如果该操作时间与当前时间差超过七天，则自动将订单状态转换为已完成。
    orders.each do |order|
      delivered_order_log = order.order_logs.where("action_number = ? and operate_time < ?",
                                                   Settings.ORDER.STATUS.DELIVERED,
                                                   Time.zone.now - 7.day).first
      if !delivered_order_log.nil?
        order.update(status: Settings.ORDER.STATUS.COMPLETED)
      end
    end
  end

end