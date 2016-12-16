require 'json'
require 'rexml/document'
include REXML

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
    params['detail']['goods_detail'] = generate_detail(order)
    params['out_trade_no'] = order.order_number
    params['total_fee'] = self.convert_yuan_fen(order.pay_price)
    # params['time_start'] = order.time_start
    # params['time_expire'] = order.time_expire
    params['openid'] = self.get_wx_openid(order)
    params['sign'] = self.generate_sign(params)

    # 参数组织为xml格式
    xml_params = self.convert_unifiedorder_params_to_xml(params)
    puts '@'*10
    puts xml_params
  end
  
  # 
  def self.generate_sign(params)
    #
    puts "9"*10
    p params
    sort_params = params.select {|k, v| !v.blank? }.sort_by {|_key, value| _key}.to_h
    puts "8"*10
    p sort_params
    #
    stringA = ""
    sort_params.each do |k, v|
      stringA += "#{k}=#{v}&"
    end
    stringA = stringA.gsub(/&$/,'')
    puts "7"*10
    p stringA
    #
    stringSignTemp = Digest::MD5.hexdigest(stringA+"&key=#{LocalConfig.WECHAT.PAY.sign_key}")
    signValue = stringSignTemp.upcase
    puts "6"*10
    p stringA
    signValue
  end

  # 获取订单商品列表
  def self.generate_detail(order)
    list = []
    order.order_details.each do |detail|
      puts "$"*10
      p detail
      product = detail.product
      data = LocalConfig.WECHAT.PAY.unifiedorder_product_details.as_json
      data["goods_id"] = product.uuid#product_number
      data["goods_name"] = product.name
      data["quantity"] = detail.quantity
      data["price"] = self.convert_yuan_fen(detail.price)
    list << data.to_json
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
    access_token_res = JSON.parse(HttpService.get(Settings.WECHAT.PAGE_ACCESS_TOKEN.URL,
                                                  access_token_params))
    if self.is_response_error?(access_token_res)
      # 获取网页授权access_token失败，打印log
      return
    end

    # 检验授权凭证（access_token）是否有效
    check_access_token_params = Settings.WECHAT.PAGE_ACCESS_TOKEN.AUTH_ACCESS_TOKEN.QUERY_PARAMS.as_json
    check_access_token_params["access_token"] = access_token_res["access_token"]
    check_access_token_params["openid"] = access_token_res["openid"]
    auth_res = JSON.parse(HttpService.get(Settings.WECHAT.PAGE_ACCESS_TOKEN.AUTH_ACCESS_TOKEN.URL,
                                          check_access_token_params))
    if auth_res["errcode"] != 0 && auth_res["errmsg"] != "ok"
      # 检验授权凭证失败,打印log.
      return
    end
    
    # 微信授权登录成功后本系统自动创建customer
    customer = CustomersService.update_customer_by_wechat(access_token_res)

    # 刷新access_token（如果需要）
    # TODO 暂不需要

    # 拉取用户信息(需scope为 snsapi_userinfo)
    if access_token_res["scope"] == Settings.WECHAT.PAGE_ACCESS_TOKEN.SCOPE.snsapi_userinfo
      user_info_params = Settings.WECHAT.PAGE_ACCESS_TOKEN.GET_USERINFO.QUERY_PARAMS.as_json
      user_info_params["access_token"] = access_token_res["access_token"]
      user_info_params["openid"] = access_token_res["openid"]
      user_info_res = JSON.parse(HttpService.get(Settings.WECHAT.PAGE_ACCESS_TOKEN.GET_USERINFO.URL,
                                                 user_info_params))
      if self.is_response_error?(user_info_res)
        # 拉去用户信息失败,打印log.
        return
      end

      # 更新微信用户信息到本地customer记录
      customer = CustomersService.update_customer_by_wechat(user_info_res)
    end

    Account.find(customer.account_id)
  end

  def self.is_response_error?(res)
    !res["errcode"].blank? && !res["errmsg"].blank?
  end

  def self.get_wx_openid(order)
    eval(order.buyer_type).find(order.buyer_id).openid
  end

  def self.collect_goods_detail(product)
    
  end

  def self.convert_unifiedorder_params_to_xml(params)
    root_ele = Element.new 'xml'
    params.each do |key, value|
      if key != "detail"
        temp = root_ele.add_element(key)
        temp.add_text(value.to_s)
      else
        detail_cdata = ''
        CData.new(value.inspect).write(detail_cdata)
        temp = root_ele.add_element(key)
        temp.add_text(detail_cdata)
      end
    end
    root_ele.to_s.gsub('&lt;','<').gsub('&gt','>').gsub('&quot;','"')
  end

end