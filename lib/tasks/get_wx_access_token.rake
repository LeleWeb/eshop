require File.expand_path('../../../app/services/base_service', __FILE__)
require File.expand_path('../../../app/services/wechat_service', __FILE__)

task :get_wx_access_token => :environment do
  puts "Hello World!"
  # 刷新公众号access_token
  WechatService.update_access_token
  # 刷新公众号调用微信临时票据
  WechatService.update_jsapi_ticket
end