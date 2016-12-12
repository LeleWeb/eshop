class QrcodeService < BaseService
  def create_qrcode
    res = HttpService.post(Settings.WECHAT.CREATE_QRCODE_URL + "?access_token=b0v-05j8uXiDhsALqXUpIfgS5XEIFQzAFrsUZP56eapvVZhE_hYtu4jDGuSAzyMtSyWibEDFh-ClAvH8UP1acdijUnUNjdscx4Uyg_Ila9xuZjolJ1916naB_ysi5MTHOTIcAJAHMB",
                           Settings.WECHAT.FOREVER_QRCODE_POST_PARAMS.QRCODE_POST_PARAMS_STR)
    puts res
    res
  end

end