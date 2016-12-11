class QrcodeService < BaseService
  def create_qrcode
    res = HttpService.post(Settings.WECHAT.CREATE_QRCODE_URL + "?access_token=YllhuL6vFw0m8V-8djq97uVjt3cSvHHVqALl76SmYvhYsi5OZJWYcrKAqh2Zukw0x-qi1vaFRepgFjiB3-Hfjmy1sfkgE-1Td9GqM2aMLBtAGQMGGUdfkwqCyny6bnScHBOgAJAWQD",
                           Settings.WECHAT.FOREVER_QRCODE_POST_PARAMS.QRCODE_POST_PARAMS_STR)
    puts res
    res
  end

end