class WechatService < BaseService
  def get_wechat(wechat_params)
    # 判断是否存必要的参数：signature,timestamp,nonce,echostr
    if wechat_params['signature'].blank? ||
        wechat_params['timestamp'].blank? ||
            wechat_params['nonce'].blank? ||
                wechat_params['echostr'].blank?
      return 'Invalid Params!'
    end

    # 验证微信Token合法性
    if check_signature(wechat_params, Settings.WECHAT.WECHAT_TOKEN)
      return wechat_params["echostr"]
    else
      return 'Check Signature Failed!'
    end
  end

  def create_wechat(params)
    params
  end

  def check_signature(wechat_params, wechat_token)
    # token,timestamp,nonce字典排序得到字符串list
    list = [wechat_token, wechat_params['timestamp'], wechat_params['nonce']].sort.join
    # 哈希算法加密得到hashcode
    hashcode = Digest::SHA1.hexdigest(list)
    # 比较hashcode与signature是否相等
    hashcode == wechat_params['signature']
  end

  # 微信统一下单接口
  def self.create_unifiedorder(order)
    # 组织统一下单参数
    params = LocalConfig.WECHAT.PAY.unifiedorder.as_json
    params['nonce_str'] = SecureRandom.hex
    params['detail'] = generate_detail(order)
    params['out_trade_no'] = order.order_number
    params['total_fee'] = self.convert_yuan_fen(order.pay_price)
    params['time_start'] = order.time_start
    params['time_expire'] = order.time_expire
    params['openid'] = ""
    params['sign'] = self.generate_sign(params)

    # 参数组织为xml格式
    xml_params = self.convert_hash_to_xml(params)


  end
  
  # 
  def self.generate_sign(params)
    #
    sort_params = params.select {|k,v| v != ""}.sort_by {|_key, value| value}.to_h

    #
    stringA = ""
    sort_params.each do |k, v|
      stringA += "#{k}=#{v}&"
    end
    stringA = stringA.gsub(/&$/,'')

    #
    stringSignTemp = Digest::MD5.hexdigest(stringA+"&key=#{Settings.WECHAT.PAY.sign_key}")
    signValue = stringSignTemp.upcase
  end

  # 获取订单商品列表
  def self.generate_detail(order)
    list = []
    order.order_details.each do |detail|
      product = detail.product
      data = LocalConfig.WECHAT.PAY.unifiedorder_product_details.as_json
      data["goods_id"] = product.product_number
      data["goods_name"] = product.name
      data["quantity"] = detail.quantity
      data["price"] = self.convert_yuan_fen(detail.price)
    list << collect_goods_detail(product)
    end
    list
  end

  # 微信统一下单接口单价单位为分，此方法负责转换.
  def self.convert_yuan_fen(price)
    price*100
  end

  # 根据订单详情计算订单总金额，单位为：分.
  def self.calculate_total_price(order)
    total_price = 0
    order.order_details.each do |detail|
      total_price += detail
    end
  end

  # 网页授权获取用户基本信息
  def self.get_wx_page_authorization_userinfo(query_params)
    # 用户同意授权，获取code
    code = query_params[:code]
    state = query_params[:state]

    # 通过code换取网页授权access_token
    access_token_params = Settings.WECHAT.PAGE_ACCESS_TOKEN.QUERY_PARAMS.as_json
    access_token_params["appid"] = LocalConfig.WECHAT.appid
    access_token_params["secret"] = LocalConfig.WECHAT.secret
    access_token_params["code"] = code
    access_token_res = HttpService.get(Settings.WECHAT.PAGE_ACCESS_TOKEN.URL,
                                       access_token_params).as_json
    if !access_token_res["errcode"].blank? && !access_token_res["errmsg"].blank?
      return
    end
    
    # 微信授权登录成功后本系统自动创建customer
    #CustomersService.

    # 刷新access_token（如果需要）
    # TODO 暂不需要

    p "$"*10
    p access_token_res
    # 拉取用户信息(需scope为 snsapi_userinfo)
    if access_token_res["scope"] == Settings.WECHAT.PAGE_ACCESS_TOKEN.SCOPE.snsapi_userinfo
      user_info_params = Settings.WECHAT.PAGE_ACCESS_TOKEN.GET_USERINFO.QUERY_PARAMS.as_json
      user_info_params["access_token"] = access_token_res["access_token"]
      user_info_params["openid"] = access_token_res["openid"]
      user_info_res = HttpService.get(Settings.WECHAT.PAGE_ACCESS_TOKEN.GET_USERINFO.URL,
                                      user_info_params).as_json
      p "#"*10
      p user_info_res
    end

    # 检验授权凭证（access_token）是否有效

  end

end