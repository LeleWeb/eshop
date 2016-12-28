class DistributionQrcodeService < BaseService
  def create_qrcode(customer)
    # 调用草料二维码来生成，后期可以将源码直接集成到本系统。
    query_params = Settings.DISTRIBUTION_QRCODE.CLI_CREATE_QRCODE.QUERY_PARAMS.as_json
    query_params["text"] = #"http://www.yiyunma.com/#/detail?product_id=#{product.id}"
    res_string = HttpService.get(Settings.DISTRIBUTION_QRCODE.CLI_CREATE_QRCODE.URL, query_params)
    CommonService.response_format(ResponseCode.COMMON.OK, DistributionQrcodeService.parse_qrcode_img(res_string))
  end

  # 草料生成二维码的接口返回的是html格式数据，需要解析出图片的地址按照json格式返回给前端。
  def self.parse_qrcode_img(str)
    if str =~ /<img src=\"([^\"]*)\"/
      $1
    else
      ''
    end
  end

end