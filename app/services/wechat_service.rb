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

    params['sign'] = self.generate_sign(params)
  end
  
  # 
  def self.generate_sign(params)
    # TODO
  end

  # 获取订单商品列表
  def self.generate_detail(order)
    list = []
    order.products.each do |product|
      data = LocalConfig.WECHAT.PAY.unifiedorder_product_details.as_json
      data["goods_id"] = product.uuid
      data["goods_name"] = product.name
      data["quantity"] = order.amount
      data["price"] = ""
    list << collect_goods_detail(product)
    end
    list
  end

end