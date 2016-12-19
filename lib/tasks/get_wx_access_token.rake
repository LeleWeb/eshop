require File.expand_path('../../../app/services/base_service', __FILE__)
require File.expand_path('../../../app/services/wechat_service', __FILE__)

task :get_wx_access_token do
  puts "Hello World!"
  WechatService.update_access_token
end