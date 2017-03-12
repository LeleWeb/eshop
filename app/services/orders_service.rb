class OrdersService < BaseService
  def get_orders(query_params)
    LOG.info %Q{#{__FILE__},#{__LINE__},#{__method__},params:
                                                        query_params: #{query_params.inspect} }

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

    # 查询指定支付方式的所有订单
    if !query_params[:pay_away].blank?
      query_condition[0] += " AND pay_away = ? "
      query_condition << query_params[:pay_away]
    end

    # 查询指定时间区间的订单
    if !query_params[:begin_time].blank? && !query_params[:end_time].blank?
      query_condition[0] += " AND created_at >= ? AND created_at <= ? "
      query_condition << query_params[:begin_time]
      query_condition << query_params[:end_time]
    end

    # 查询未处理的订单(包括：在线已支付订单和货到付款的未完成订单)
    if query_params[:type] == 'untreated'
      # 查询在线支付的已付款订单和货到付款的未支付订单
      query_condition[0] += " AND status = ? AND pay_away = ? OR status = ? AND pay_away = ? "
      query_condition << Settings.ORDER.STATUS.PAID
      query_condition << Settings.ORDER.PAY_AWAY.WXPAY.VALUE
      query_condition << Settings.ORDER.STATUS.PREPAY
      query_condition << Settings.ORDER.PAY_AWAY.COD.VALUE
    end

    # 默认按照支付时间将序排列
    orders = Order.where(query_condition).order(payment_time: :desc)

    # 如果存在分页参数,按照分页返回结果.
    if !query_params[:page].blank? && !query_params[:per_page].blank?
      orders = eval(orders.nil? ? "Order" : "orders").
               page(query_params[:page]).
               per(query_params[:per_page])
      total_count = orders.total_count
    else
      total_count = orders.size
    end

    CommonService.response_format(ResponseCode.COMMON.OK, OrdersService.get_orders(orders, total_count))
  end

  def get_order(order)
    LOG.info %Q{#{__FILE__},#{__LINE__},#{__method__},params:
                                                        order: #{order.inspect} }

    CommonService.response_format(ResponseCode.COMMON.OK, OrdersService.get_order(order))
  end

  # 创建订单
  def create_order(order_params)
    LOG.info %Q{#{__FILE__},#{__LINE__},#{__method__},params:
                                                        order_params: #{order_params.inspect} }

    order_total_price = 0.0

    # 参数合法性检查
    if order_params.blank?
      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "ERROR: order_params:#{order_params} is blank!")
    end

    # 解析下单用户
    begin
      buyer = Customer.find(order_params.extract!("buyer_id")["buyer_id"])
    rescue Exception => e
      # TODO 解析下单用户失败，打印对应log
      LOG.error "Error: file: #{__FILE__} line:#{__LINE__} find order buyer failed! Details: #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "Error: file: #{__FILE__} line:#{__LINE__} find order buyer failed! Details: #{e.message}")
    end

    # 解析收货地址对象
    begin
      address = Address.find(order_params.extract!("address_id")["address_id"])
    rescue Exception => e
      # TODO 解析收货地址对象失败，打印对应log
      LOG.error "Error: file: #{__FILE__} line:#{__LINE__} find order address failed! Details: #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "Error: file: #{__FILE__} line:#{__LINE__} find order address failed! Details: #{e.message}")
    end

    # 解析订单详情项(此处为了复用，实际为购物车项)
    begin
      shopping_carts = ShoppingCart.find(order_params.extract!("shopping_cart_ids")["shopping_cart_ids"])
    rescue Exception => e
      # TODO 解析订单详情项失败，打印对应log
      LOG.error "Error: file: #{__FILE__} line:#{__LINE__} find shopping_carts failed! Details: #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "Error: file: #{__FILE__} line:#{__LINE__} find shopping_carts failed! Details: #{e.message}")
    end

    begin
      Order.transaction do
        # 生成本系统订单
        begin
          order_params["order_number"] = OrdersService.generate_order_number(buyer.id)
          order_params["status"] = Settings.ORDER.STATUS.PREPAY
          # order_params["pay_away"] = 1 # 改为由前端参数传入，用来支持货到付款方式。
          order_params["time_start"] = Time.now.strftime("%Y%m%d%H%M%S")
          order_params["time_expire"] = (Time.now + Settings.ORDER.EXPIRE_TIME.to_i).strftime("%Y%m%d%H%M%S")
          order = buyer.orders.create!(order_params.merge("consignee_address" => address.address,
                                                          "consignee_name" => address.name,
                                                          "consignee_phone" => address.phone))
        rescue Exception => e
          # TODO 生成本系统订单失败，打印对应log
          LOG.error "Error: file: #{__FILE__} line:#{__LINE__} create system order failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # 生成对应的订单详情项
        begin
          shopping_carts.each do |shopping_cart|
            # 先设置购物车项的property属性为：1-订单详情项
            shopping_cart.update!(property: Settings.CART_OR_ITEM.PROPERTY.ORDER_DETAILS_ITEM)
            # 累加订单总金额
            order_total_price += shopping_cart.total_price
            # 与订单建立关联
            order.shopping_carts << shopping_cart
            # 此处将订单关联资源的必要信息都拷贝到订单详情项的对应字段中
            OrdersService.update_shopping_cart_product_info(shopping_cart)

            # 如果是多商品购物车，则需要将该节点下的子项设置由购物车项为订单项。
            if !shopping_cart.subitems.blank?
              shopping_cart.subitems.each do |subitem|
                subitem.update!(property: Settings.CART_OR_ITEM.PROPERTY.ORDER_DETAILS_ITEM)
                # 累加订单总金额
                order_total_price += subitem.total_price
              end
            end
          end
        rescue Exception => e
          # TODO 生成对应的订单详情项失败，打印对应log
          LOG.error "Error: file: #{__FILE__} line:#{__LINE__} create order detail failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # 设置实际支付订单为订单总额
        begin
          order.update(pay_price: order_total_price, total_price: order_total_price)
        rescue Exception => e
          # TODO 设置实际支付订单为订单总额失败，打印对应log
          LOG.error "Error: file: #{__FILE__} line:#{__LINE__} set order total_price failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # 此处根据支付方式不同做相应处理
        begin
          if order.pay_away == Settings.ORDER.PAY_AWAY.WXPAY.VALUE
            # 调用微信统一接口,生成预付订单.
            res = WechatService.create_unifiedorder(order)
            CommonService.response_format(ResponseCode.COMMON.OK, {"order" => self.get_order(order), "prepay_data" => res})
          elsif order.pay_away == Settings.ORDER.PAY_AWAY.COD.VALUE
            # 货到付款
            order.update!(status: Settings.ORDER.STATUS.PREPAY)
            CommonService.response_format(ResponseCode.COMMON.OK, {"order" => self.get_order(order)})
          end
        rescue Exception => e
          # TODO 设置实际支付订单为订单总额失败，打印对应log
          LOG.error "Error: file: #{__FILE__} line:#{__LINE__} set order total_price failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end
      end
    rescue Exception => e
      # TODO 打印log
      LOG.error "Error: file: #{__FILE__} line:#{__LINE__} 创建订单失败! Details: #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "Error: file: #{__FILE__} line:#{__LINE__} 创建订单失败! Details: #{e.message}")
    end
  end

  # def create_order(buyer, address, order_params, details)
  #   # 生成本系统订单
  #   order_params[:order_number] = OrdersService.generate_order_number(buyer.id)
  #   order_params[:status] = Settings.ORDER.STATUS.PREPAY
  #   order_params[:pay_away] = 1
  #   order_params[:time_start] = Time.now.strftime("%Y%m%d%H%M%S")
  #   order_params[:time_expire] = (Time.now + Settings.ORDER.EXPIRE_TIME.to_i).strftime("%Y%m%d%H%M%S")
  #   order = buyer.orders.create(order_params.merge("consignee_address" => address.address,
  #                                                  "consignee_name" => address.name,
  #                                                  "consignee_phone" => address.phone))
  #   # 暂时设置实际支付订单为订单总额
  #   order.update(pay_price: order.total_price)
  #
  #   # 生成对应的订单详情项
  #   details.each do |detail|
  #     order.order_details.create(detail.permit(:product_id, :quantity, :price))
  #   end
  #
  #   # 删除订单对应的购物车商品
  #   CartsService.delete_shopping_cart(buyer, order)
  #
  #   # 调用微信统一接口,生成预付订单.
  #   res = WechatService.create_unifiedorder(order)
  #
  #   CommonService.response_format(ResponseCode.COMMON.OK, {"order" => order, "prepay_data" => res})
  # end

  # def update_order(order, order_params)
  #   if order.update(order_params)
  #     CommonService.response_format(ResponseCode.COMMON.OK, order)
  #   else
  #     ResponseCode.COMMON.FAILED['message'] = order.errors
  #     CommonService.response_format(ResponseCode.COMMON.FAILED)
  #   end
  # end

  def destory_order(order)
    LOG.info %Q{#{__FILE__},#{__LINE__},#{__method__},params:
                                                        order: #{order.inspect} }

    begin
      Order.transaction do
        # 删除订单
        begin
          order.update!(is_deleted: true, deleted_at: Time.now)
        rescue Exception => e
          # TODO 删除订单失败，打印对应log
          LOG.error "Error: file: #{__FILE__} line:#{__LINE__} destroy order failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # TODO 删除订单与订单详情关联关系
        begin
          order.shopping_carts.map{|x| x.update!(is_deleted: true, deleted_at: Time.now)}
        rescue Exception => e
          # TODO 删除订单与订单详情关联关系失败，打印对应log
          LOG.error "Error: file: #{__FILE__} line:#{__LINE__} destroy order and detail relation failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end
      end
    rescue Exception => e
      # TODO 打印log
      LOG.error "Error: file: #{__FILE__} line:#{__LINE__} 删除订单失败! Details: #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "Error: file: #{__FILE__} line:#{__LINE__} 删除订单失败! Details: #{e.message}")
    end

    CommonService.response_format(ResponseCode.COMMON.OK)
  end

  def print_order(order)
    LOG.info %Q{#{__FILE__},#{__LINE__},#{__method__},params:
                                                        order: #{order.inspect} }

    # 参数合法性检查
    if order.blank?
      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "ERROR: order:#{order.inspect} is blank!")
    end

    # 打印订单小票
    res = OrdersService.print_order(order)

    CommonService.response_format(ResponseCode.COMMON.OK, res)
  end

  def self.get_order(order)
    order.as_json.merge("order_details" => CartsService.get_carts_no_count(order.shopping_carts))
  end

  def self.get_orders(orders, total_count)
    data = orders.collect{|order| self.get_order(order)}
    {"total_count" => total_count.nil? ? orders.length : total_count, "orders" => data}
  end

  def self.get_orders_no_count(orders)
    orders.collect{|order| self.get_order(order)}
  end

  # 定时刷新订单状态，已发货的订单，超过七天后自动设置为已完成方法。
  def self.update_order_status
    LOG.info %Q{#{__FILE__},#{__LINE__},#{__method__} }

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

  def self.print_order(order)
    LOG.info %Q{#{__FILE__},#{__LINE__},#{__method__},params:
                                                        order: #{order.inspect} }

    # 收集订单相关数据
    order_info = self.get_order(order)
    # 格式化为打印机可以接受的数据格式
    content = self.format_print_data(order_info)
    # 调用打印机接口打印
    self.printcenter_365_s2(content)
  end

  def self.format_print_data(order)
    LOG.info %Q{#{__FILE__},#{__LINE__},#{__method__},params:
                                                        order: #{order.inspect} }

    content =  ""
    # 头部信息
    content += "<CB>舌尖生鲜</CB>"
    content += "<C>Fresh Town</C>"
    content += "--------------------------------<BR>"
    content += "订单编号：#{order["order_number"]}<BR>"
    # content += "员工：张伟<BR>"
    content += "下单时间：#{order["created_at"].strftime('%Y-%m-%d %H:%M:%S')}<BR>"
    content += "收货人名：#{order["consignee_name"]}<BR>"
    content += "电话号码：#{order["consignee_phone"]}<BR>"
    content += "配送地址：#{order["consignee_address"]}<BR>"
    content += "配送时间：#{order["delivery_time"].strftime('%Y-%m-%d %H:%M:%S')}<BR>"
    content += "支付方式：#{self.get_pay_way(order["pay_away"])}<BR>"
    # 商品清单列表
    content += "--------------------------------<BR>"
    content += self.format_content("名称") + self.format_head("单价") + self.format_head("数量") + self.format_head("金额") + "<BR>"
    content += "--------------------------------<BR>"
    order["order_details"].each do |order_detail|
      # 区分是否是团队套餐
      if !order_detail["subitems"].blank?
        # 团队套餐
        content += self.get_team_content(order_detail)
      else
        # 单品
        content += self.get_single_content(order_detail)
      end
    end

    # content += self.format_content("红富士苹果脆甜可口不打啦") + self.format_value("999.9") + self.format_value("999.9") + self.format_value("999.9") + "<BR>"
    # content += self.format_content("香蕉") + self.format_value("1") + self.format_value("2.3") + self.format_value("2") + "<BR>"
    # content += self.format_content("火龙果") + self.format_value("1.0") + self.format_value("20.3") + self.format_value("9") + "<BR>"
    #
    # # 个人套餐
    # # content += self.format_product_name("个人套餐：") + "<BR>"
    # content += self.format_content("个人套餐：") + "<BR>"
    # content += self.format_content("瘦身型", 1, 6) + self.format_value("999.9") + self.format_value("999.9") + self.format_value("999.9") + "<BR>"
    # content += self.format_content("美容型超长测试测试", 1, 6) + self.format_value("999.9") + self.format_value("999.9") + self.format_value("999.9") + "<BR>"
    #
    content += "--------------------------------<BR>"
    content += self.format_content("") + self.format_head("合计：") + format("%12s", order["pay_price"].to_s) + "<BR>"
    content += "--------------------------------<BR>"
    # 商家信息
    content += "公司：西安当夏网络科技有限公司<BR>"
    content += "地址：丈八西路东滩社区31排5号<BR>"
    content += "电话：18161803190"
    # 二维码
    content += "<QR>http://open.printcenter.cn</QR>"
    content
  end

  def self.printcenter_365_s2(content)
    params = LocalConfig.ORDER_PRINT.PRINTCENTER_365_S2.INFO.as_json
    params["printContent"] = content
    res = CommonService.post(LocalConfig.ORDER_PRINT.PRINTCENTER_365_S2.URL, params)
    if !res.blank? && res["responseCode"] != Settings.PRINTCENTER.RESPONSE.OK
      # TODO 执行打印异常，打印log记录，调用异常处理方法。
    end
    res
  end

  # 格式化商品名称信息
  def self.format_content(name, prefix_offset=0, total=7)
    name = name[0, total]
    format(" "*prefix_offset*2 + "%-#{total + total - name.length}s", name)
  end

  # 格式化商品列表头信息
  def self.format_head(value)
    value = value[0,3]
    format("%#{3 + 3 - value.length}s", value)
  end

  # 格式化商品价格信息
  def self.format_value(value)
    format("%6s", value)
  end

  def self.get_single_content(order_detail)
    LOG.info %Q{#{__FILE__},#{__LINE__},#{__method__},params:
                                                        order_detail: #{order_detail.inspect} }
    self.format_content(order_detail["product"]["name"]) +
        self.format_value(order_detail["price"]["real_price"]) +
        self.format_value(order_detail["amount"]) +
        self.format_value(order_detail["total_price"]) +
        "<BR>"
  end

  def self.get_team_content(order_detail)
    content = ""
    content += self.format_content("团队套餐：") + "<BR>"
    order_detail["subitems"].each do |subitem|
      content += self.get_single_content(subitem)
    end
    content
  end

  def self.get_pay_way(value)
    case value
    when Settings.ORDER.PAY_AWAY.WXPAY.VALUE
      Settings.ORDER.PAY_AWAY.WXPAY.TEXT
    when Settings.ORDER.PAY_AWAY.COD.VALUE
      Settings.ORDER.PAY_AWAY.COD.TEXT
    else
      ''
    end
  end

  # 订单支付成功后的回调事件接口
  def self.wxpay_notify_callback(order)
    # 团购商品支付成功后的数据更新
    ProductsService.update_product_data(order)
  end

  # 订单项关联的商品和价格需要从关联的对象拷贝必要字段到商品详情项记录的对应字段
  def self.update_shopping_cart_product_info(shopping_cart)
    LOG.info %Q{#{__FILE__},#{__LINE__},#{__method__},params:
                                                        shopping_cart: #{shopping_cart.inspect} }

    begin
      product = Product.find(shopping_cart.product_id)
      image = product.images.where(category: Settings.PICTURES_CATEGORY.PRODUCT.MAIN).first
      price = Price.find(shopping_cart.price_id)
      shopping_cart.update!(product_img: image.documents.first.document,
                            product_name: product.name,
                            product_desc: product.description,
                            product_price: price.real_price,
                            product_unit: price.unit)
    rescue Exception => e
      # TODO 订单项关联的商品和价格需要从关联的对象拷贝必要字段到商品详情项记录的对应字段失败，打印对应log
      LOG.error "Error: file: #{__FILE__} line:#{__LINE__} update_shopping_cart_product_info failed! Details: #{e.message}"

      # 继续向上层抛出异常
      raise e
    end
  end

end