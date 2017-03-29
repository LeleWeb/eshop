require 'json'
require 'digest/sha1'
require 'rexml/document'
include REXML

class WechatService < BaseService
  def get_wechat(wechat_params)
    LOG.info %Q{#{__FILE__},#{__LINE__},#{__method__},params:
                                                        wechat_params: #{wechat_params.inspect} }

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
    LOG.info %Q{#{__FILE__},#{__LINE__},#{__method__},params:
                                                        params: #{params.inspect} }

    # TODO 验证微信服务器合法性

    params = params["xml"]
    #
    case params["MsgType"]
      when "event"
        WxmessagesService.new.wxmessages_management(params)
    end
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
    LOG.info %Q{#{__FILE__},#{__LINE__},#{__method__},params:
                                                        order: #{order.inspect},
                                                        openid: #{eval(order.buyer_type).find(order.buyer_id).openid} }

    # 组织统一下单参数
    params = LocalConfig.WECHAT.PAY.unifiedorder.as_json
    LOG.info(params.inspect)
    params['nonce_str'] = self.generate_nonce_str
    # params['detail']['goods_detail'] = generate_detail(order)
    params['out_trade_no'] = order.order_number
    params['total_fee'] = self.convert_yuan_fen(order.pay_price)
    # params['time_start'] = order.time_start
    # params['time_expire'] = order.time_expire
    params['openid'] = self.get_wx_openid(order)
    params['sign'] = self.generate_sign(params)
    LOG.info(params.inspect)

    # 参数组织为xml格式
    xml_params = self.convert_unifiedorder_params_to_xml(params)
    LOG.info('1'*10)
    LOG.info(xml_params)

    # 发送统一下单请求
    req_headers = [
                    {:key => Settings.REQUEST_HEADERS.CONTENT_TYPE_KEY, :value => Settings.REQUEST_HEADERS.CONTENT_TYPE_VALUE.XML}
                  ]
    res_xml = HttpService.post(Settings.WECHAT.UNIFIEDORDER_URL,
                           xml_params,
                           req_headers)

    # 统一支付接口调用返回xml结果转换为hash
    res_hash = Hash.from_xml(res_xml)["xml"]
    LOG.info '2'*10
    LOG.info res_hash

    if res_hash["return_code"] != "SUCCESS" || res_hash["result_code"] != "SUCCESS"
      return {
          "return_code" => res_hash["return_code"],
          "return_msg" => res_hash["return_msg"],
          "result_code" => res_hash["result_code"],
          "err_code" => res_hash["err_code"],
          "err_code_des" => res_hash["err_code_des"],
      }
    end

    # 网页端调起支付API所需参数生成
    prepay_data = self.generate_jsapi_params(res_hash)
    LOG.info '3'*10
    LOG.info prepay_data
    prepay_data
  end
  
  # 
  def self.generate_sign(params, encrypt_type="Digest::MD5")
    #
    sort_params = params.select {|k, v| !v.blank? }.sort_by {|_key, value| _key}.to_h

    #
    stringA = ""
    sort_params.each do |k, v|
      stringA += "#{k}=#{v}&"
    end
    stringA = stringA.gsub(/&$/,'')
    puts 'c'
    p stringA
    #
    string_key = stringA+"&key=#{LocalConfig.WECHAT.PAY.sign_key}"
    puts 'd'
    p string_key
    stringSignTemp = eval(encrypt_type).hexdigest(string_key)
    signValue = stringSignTemp.upcase
    puts 'e'
    p signValue
    signValue
  end

  # 获取订单商品列表
  def self.generate_detail(order)
    list = []
    order.order_details.each do |detail|
      product = detail.product
      data = LocalConfig.WECHAT.PAY.unifiedorder_product_details.as_json
      data["goods_id"] = product.uuid#product_number
      data["goods_name"] = product.name
      data["quantity"] = detail.quantity
      data["price"] = self.convert_yuan_fen(detail.price)
    list << data
    end
    list
  end

  # 微信统一下单接口单价单位为分，此方法负责转换.
  def self.convert_yuan_fen(price)
    (price*100).to_i
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
    p 'A'*10,query_params
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
      puts "ERROR: access_token_res: #{access_token_res}!"
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
      puts "ERROR: auth_res: #{auth_res}!"
      return
    end
    
    # 微信授权登录成功后本系统自动创建customer
    customer = CustomersService.update_customer_by_wechat(access_token_res)
    p 'B'*10,customer
    customer

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
      p 'C'*10,customer
      customer
    end

    # 组成返回参数，id为当前登录的用户在本系统的id, parent_id为父级分销者的id
    {"account_id" => customer.account_id,
     "parent_account_id" => self.get_parent_distributor(state)}
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
        CData.new(value.to_json).write(detail_cdata)
        temp = root_ele.add_element(key)
        temp.add_text(detail_cdata)
      end
    end
    root_ele.to_s.gsub('&lt;','<').gsub('&gt','>').gsub('&quot;','"')
  end

  def self.generate_jsapi_params(prepay_res)
    temp_time = (self.generate_timeStamp/1000).to_s
    temp_str = self.generate_nonce_str
    signature_params = {}#Settings.WECHAT.JSAPI_PAY_SIGNATURE_PARAMS.as_json
    signature_params["jsapi_ticket"] = self.read_jsapi_ticket
    signature_params["url"] = "http://www.dangxiaweb.com/"
    signature_params["timestamp"] = temp_time
    signature_params["noncestr"] = temp_str
    config_signature = self.generate_jsapi_sign(signature_params)

    data = {}
    data["appId"] = prepay_res["appid"]
    data["timeStamp"] = (self.generate_timeStamp/1000).to_s#temp_time
    data["nonceStr"] = self.generate_nonce_str#temp_str
    data["package"] = "prepay_id=#{prepay_res["prepay_id"]}"
    data["signType"] = "MD5"
    data["paySign"] = self.generate_sign(data)#signature
    data["config_signature"] = config_signature
    data["config_timestamp"] = signature_params["timestamp"]
    data["config_noncestr"] = signature_params["noncestr"]
    data["jsapi_ticket"] = signature_params["jsapi_ticket"]
    puts "b"*10
    p data
    data
  end

  def self.generate_timeStamp
    (Time.now.to_datetime.strftime '%Q').to_i
  end

  # 生成32位随机字符串
  def self.generate_nonce_str
    SecureRandom.hex
  end

  #
  def self.generate_jsapi_sign(params, encrypt_type="Digest::SHA1")
    #
    sort_params = params.select {|k, v| !v.blank? }.sort_by {|_key, value| _key}.to_h

    #
    stringA = ""
    sort_params.each do |k, v|
      stringA += "#{k.downcase}=#{v}&"
    end
    stringA = stringA.gsub(/&$/,'')

    puts '+'*10
    puts stringA

    stringSignTemp = eval(encrypt_type).hexdigest(stringA)
    puts '+1'*10
    puts stringSignTemp
    stringSignTemp
  end
  
  # 获取微信access_token
  def self.update_access_token
    #
    query_params = ::Settings.WECHAT.ACCESS_TOKEN.QUERY_PARAMS.as_json
    query_params["appid"] = ::LocalConfig.WECHAT.appid
    query_params["secret"] = ::LocalConfig.WECHAT.secret
    res = JSON.parse(HttpService.get(::Settings.WECHAT.ACCESS_TOKEN.URL, query_params))
    if res.key?("access_token") && !res["access_token"].blank?
      # 持久化到数据库
      SystemStorage.update_storage(::Settings.WECHAT.EXPIRE_DATA.ACCESS_TOKEN, res["access_token"])
    end
  end

  # 读取有效的本地暂存access_token
  def self.read_access_token
    storage = SystemStorage.get_storage(::Settings.WECHAT.EXPIRE_DATA.ACCESS_TOKEN)
    if !storage.nil?
      return storage.content
    else
      return nil
    end
  end

  # 获取微信jsapi_ticket
  def self.update_jsapi_ticket
    req_params = {"access_token" => self.read_access_token, "type" => "jsapi"}
    res = JSON.parse(HttpService.get("https://api.weixin.qq.com/cgi-bin/ticket/getticket", req_params))
    if res["errcode"] == 0 && res["errmsg"] == "ok"
      # 持久化到数据库
      SystemStorage.update_storage(Settings.WECHAT.EXPIRE_DATA.JSAPI_TICKET, res["ticket"])
    end
  end

  # 读取有效的本地暂存jsapi_ticket
  def self.read_jsapi_ticket
    storage = SystemStorage.get_storage(Settings.WECHAT.EXPIRE_DATA.JSAPI_TICKET)
    if !storage.nil? && !storage.content.blank?
      return storage.content
    else
      self.update_access_token
      self.update_jsapi_ticket
      SystemStorage.get_storage(Settings.WECHAT.EXPIRE_DATA.JSAPI_TICKET).content
    end
  end

  # 支付签名验证
  def self.check_sign(params)
    param_sign = params.delete("sign")
    # 本地计算签名
    sign = self.generate_sign(params, encrypt_type="Digest::#{params["sign_type"].blank? ? "MD5" : params["sign_type"]}")

    # 参数签名值与计算值比较
    param_sign == sign
  end

  # 生成微信网页授权的url
  def self.create_wx_oauth2_url(state)
    url = Settings.WECHAT.WX_OAUTH2.URL
    query_parmas = "?appid=#{LocalConfig.WECHAT.appid}&redirect_uri=#{Settings.WECHAT.WX_OAUTH2.QUERY_PARAMS.redirect_uri}&response_type=#{Settings.WECHAT.WX_OAUTH2.QUERY_PARAMS.response_type}&scope=#{Settings.WECHAT.WX_OAUTH2.QUERY_PARAMS.scope}&state=#{state}#wechat_redirect"
    url + query_parmas
  end

  def self.get_parent_distributor(state)
    parent_id = ""
    if !state.blank? && state =~ /(\d+)$/ && !(parent_customer = Customer.find_by(id: $1.to_i)).nil?
      parent_id = parent_customer.account_id
    end
    parent_id
  end

end