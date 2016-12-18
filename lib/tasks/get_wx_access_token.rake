require "../../app/services/wechat_service.rb"

task :get_wx_access_token do
  puts "Hello World!"
  WechatService.get_access_token
end