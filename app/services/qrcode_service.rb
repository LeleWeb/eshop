class QrcodeService < BaseService
  def create_qrcode
    # 创建二维码ticket
    req_headers = [
        {:key => Settings.REQUEST_HEADERS.CONTENT_TYPE_KEY, :value => Settings.REQUEST_HEADERS.CONTENT_TYPE_VALUE.JSON}
    ]
    res = JSON.parse(HttpService.post(Settings.WECHAT.CREATE_QRCODE_URL + "?access_token=#{WechatService.read_access_token}",
                           Settings.WECHAT.FOREVER_QRCODE_POST_PARAMS.QRCODE_POST_PARAMS_STR.to_json,
                           req_headers))
    puts "a"*10
    puts res

    if res.key?("ticket") && !res["ticket"].blank?
      # 通过ticket换取二维码
      # HTTP GET请求（请使用https协议）https://mp.weixin.qq.com/cgi-bin/showqrcode?ticket=TICKET提醒：TICKET记得进行UrlEncode
      query_parmas = Settings.WECHAT.SHOW_QRCODE.QUERY_PARAMS.as_json
      query_parmas["ticket"] = res["ticket"]
      res = HttpService.get(Settings.WECHAT.SHOW_QRCODE.URL, query_parmas)
      puts "1"*10
      p res
      res
    end
  end

end