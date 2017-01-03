class WxmessagesService < BaseService
  def wxmessages_management(wxmessages_params)
    p 'a'*10,wxmessages_params
    # 关注事件,发送关注自动回复文字.
    if wxmessages_params["Event"] == Settings.WECHAT.WXMESSAGES.EVENT.SUBSCRIBE.KEY
      p 'b'*10,wxmessages_params
      data = {}
      data["ToUserName"] = wxmessages_params["ToUserName"]
      data["FromUserName"] = wxmessages_params["FromUserName"]
      data["CreateTime"] = wxmessages_params["CreateTime"]
      data["MsgType"] = "text"
      data["Content"] = "你好"
      p 'c'*10,xml = WxmessagesService.convert_hash_to_xml(data,
                                                           Settings.WECHAT.WXMESSAGES.EVENT.SUBSCRIBE.XML.as_json)
      xml
    else
      "success"
    end
  end

  # 微信专用xml格式转化方法
  def self.convert_hash_to_xml(params, xml_cdata_flag)
    root_ele = Element.new 'xml'
    params.each do |key, value|
      if xml_cdata_flag[key] == true
        detail_cdata = ''
        CData.new(value).write(detail_cdata)
        temp = root_ele.add_element(key)
        temp.add_text(detail_cdata)
      else
        temp = root_ele.add_element(key)
        temp.add_text(value.to_s)
      end
    end
    root_ele.to_s.gsub('&lt;','<').gsub('&gt','>').gsub('&quot;','"')
  end

end