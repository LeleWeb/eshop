# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :output, "log/cron_log.log"

#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# 获取微信获取access_token定时任务，间隔90分钟。
every 90.minutes  do
  rake "get_wx_access_token"
end

# 每天定时刷新订单状态，已发货的订单，超过七天后自动设置为已完成。
every 1.day, :at => '00:00 am' do
  rake "update_order_status"
end

