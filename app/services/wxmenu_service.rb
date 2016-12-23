class WxmenuService < BaseService
  def create_wxmenu(wxmenu_params)
    puts 'a'*10
    p wxmenu_params.to_s.gsub(/=>/, ':')
    # 调用微信创建菜单接口
    req_headers = [
        {:key => Settings.REQUEST_HEADERS.CONTENT_TYPE_KEY, :value => Settings.REQUEST_HEADERS.CONTENT_TYPE_VALUE.JSON}
    ]
    JSON.parse(HttpService.post(Settings.WECHAT.CREATE_WXMENU_URL + "?access_token=#{WechatService.read_access_token}",
                                wxmenu_params.to_s.gsub(/=>/, ':'),
                                req_headers))
  end

end