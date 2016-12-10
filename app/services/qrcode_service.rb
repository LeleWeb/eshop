class QrcodeService < BaseService
  def create_qrcode
    HttpService.post(url, params)
  end

end