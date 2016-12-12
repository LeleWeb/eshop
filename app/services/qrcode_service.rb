class QrcodeService < BaseService
  def create_qrcode
    res = HttpService.post(Settings.WECHAT.CREATE_QRCODE_URL + "?access_token=SMMF3MU_3fe7heY-1dxAnvNZWGrJKnufIvZu1AD4bMHTVPjibOWsxiMlUNaIJrF15duwW_t_Xo9THOMyfhn0nbQqPvyAqoNGdh_kRQg2hEPeUVuj9s2q2BPO2UcCitN3CWJfAGARLY",
                           Settings.WECHAT.FOREVER_QRCODE_POST_PARAMS.QRCODE_POST_PARAMS_STR)
    puts res
    res
  end

end