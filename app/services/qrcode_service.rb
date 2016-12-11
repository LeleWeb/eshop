class QrcodeService < BaseService
  def create_qrcode
    res = HttpService.post(Settings.WECHAT.CREATE_QRCODE_URL + "?access_token=72wGq0nbaDJBR_E4lxeq-TsirFIGSkF6XumLH6HFYF4DaOueuH8_Ii0LVdMQZXYy7t_CgrmkCyPqCEw1UEp5NTO1q2LZvq_D-7BPEv2L0AKrQeH4WEQfirqMcgBNw4HiYZCbAHADEH",
                           Settings.WECHAT.FOREVER_QRCODE_POST_PARAMS.QRCODE_POST_PARAMS_STR)
    puts res
    res
  end

end