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

  def check_signature(wechat_params, wechat_token)
    # token,timestamp,nonce字典排序得到字符串list
    list = [wechat_token, wechat_params['timestamp'], wechat_params['nonce']].sort.join
    # 哈希算法加密得到hashcode
    hashcode = Digest::SHA1.hexdigest(list)
    # 比较hashcode与signature是否相等
    hashcode == wechat_params['signature']
  end

end