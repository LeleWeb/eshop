class DistributionQrcodeService < BaseService
  def create_qrcode
    # 调用草料二维码来生成，后期可以将源码直接集成到本系统。
    query_params = Settings.DISTRIBUTION_QRCODE.CLI_CREATE_QRCODE.QUERY_PARAMS.as_json
    query_params["text"] = "http://www.yiyunma.com/#/detail?product_id=1"
    res_string = HttpService.get(Settings.WECHAT.PAGE_ACCESS_TOKEN.URL, query_params)
    CommonService.response_format(ResponseCode.COMMON.OK, self.parse_qrcode_img(res_string))
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