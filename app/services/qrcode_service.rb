class QrcodeService < BaseService
  def create_qrcode
    res = HttpService.post(Settings.WECHAT.CREATE_QRCODE_URL + "?access_token=U2EyPdV705JIOyeZpeMOKKpidciG-24jzGZiDBGY_SDnVUObZYgUCyGMccL8dX8HRhCDdAqxsRafxo_qS0KMqQ8Y5b1YyTYbpkB-H_aMSGxJDDxMEDbL19SqL2YLR_oCZQHfAEAOFW",
                           Settings.WECHAT.FOREVER_QRCODE_POST_PARAMS.QRCODE_POST_PARAMS_STR)
    puts res
    res
  end

end