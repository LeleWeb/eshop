class OrdersService < BaseService
  def get_orders(query_params)
    # 根据参数，解析所有查询条件
    orders = []
    total_count = nil

    query_condition = [" 1 AND 1 "]

    # 查询指定消费者的订单
    if !query_params[:buyer_type].blank? && !query_params[:buyer_id].blank?
      query_condition[0] += " AND buyer_type = ? AND buyer_id = ? "
      query_condition << query_params[:buyer_type]
      query_condition << query_params[:buyer_id]
    end

    # 查询指定状态的订单
    if !query_params[:status].blank?
      query_condition[0] += " AND status = ? "
      query_condition << query_params[:status]
    end

    # 查询指定时间区间的订单
    if !query_params[:begin_time].blank? && !query_params[:end_time].blank?
      query_condition[0] += " AND created_at >= ? AND created_at <= ? "
      query_condition << query_params[:begin_time]
      query_condition << query_params[:end_time]
    end

    # 默认按照支付时间将序排列
    orders = Order.where(query_condition).order(payment_time: :desc)

    # 判断是否需要分页
    if !query_params[:page].blank? && !query_params[:per_page].blank?
      orders = orders.page(query_params[:page]).per(query_params[:per_page])
      total_count = orders.total_count
    end

    CommonService.response_format(ResponseCode.COMMON.OK, OrdersService.get_orders(orders, total_count))
  end

  def get_order(order)
    CommonService.response_format(ResponseCode.COMMON.OK, OrdersService.get_order(order))
  end

  def create_order(buyer, address, order_params, details)
    # 生成本系统订单
    order_params[:order_number] = OrdersService.generate_order_number(buyer.id)
    order_params[:status] = Settings.ORDER.STATUS.PREPAY
    order_params[:pay_away] = 1
    order_params[:time_start] = Time.now.strftime("%Y%m%d%H%M%S")
    order_params[:time_expire] = (Time.now + Settings.ORDER.EXPIRE_TIME.to_i).strftime("%Y%m%d%H%M%S")
    order = buyer.orders.create(order_params.merge("consignee_address" => address.address,
                                                   "consignee_name" => address.name,
                                                   "consignee_phone" => address.phone))
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

  def self.get_order(order)
    order.as_json.merge("order_details" => order.order_details.collect{|order_detail| order_detail.as_json.merge("product" => ProductsService.find_product_data(order_detail.product))})
  end

  def self.get_orders(orders, total_count)
    data = []
    orders.each do |order|
      data << self.get_order(order)
    end

    {"total_count" => total_count.nil? ? data.count : total_count, "orders" => data}
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
        # 唯一刷新订单状态为完成的地方
        order.update(status: Settings.ORDER.STATUS.COMPLETED)

        # 此处完成以当前订单的customer为分销节点为起始，往上两级的祖先节点的账户明细刷新.
        DistributionsService.update_customer_account_details(order)
      end
    end
  end

  # 2017.2.11 修改订单编号编码规则为: 本系统用户id + 当前时间格式。
  def self.generate_order_number(user_id)
    "%05d" % user_id.to_i + Time.new.strftime("%Y%m%d%H%M%S")
  end

  # 2017.2.11 修改订单编号编码规则为: 本系统用户id + 当前时间格式。脚本方法。
  def self.update_order_number
    Order.all.each do |order|
      order.update(order_number: self.generate_order_number(order.id))
    end
  end

end