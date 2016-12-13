class QrcodeService < BaseService
  def create_qrcode
    # 创建二维码ticket
    res = HttpService.post(Settings.WECHAT.CREATE_QRCODE_URL + "?access_token=b0v-05j8uXiDhsALqXUpIfgS5XEIFQzAFrsUZP56eapvVZhE_hYtu4jDGuSAzyMtSyWibEDFh-ClAvH8UP1acdijUnUNjdscx4Uyg_Ila9xuZjolJ1916naB_ysi5MTHOTIcAJAHMB",
                           Settings.WECHAT.FOREVER_QRCODE_POST_PARAMS.QRCODE_POST_PARAMS_STR)
    puts res

    # 通过ticket换取二维码
    # HTTP GET请求（请使用https协议）https://mp.weixin.qq.com/cgi-bin/showqrcode?ticket=TICKET提醒：TICKET记得进行UrlEncode

    res
  end

end