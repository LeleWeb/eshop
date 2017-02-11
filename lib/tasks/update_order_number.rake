require File.expand_path('../../../app/services/base_service', __FILE__)
require File.expand_path('../../../app/services/orders_service', __FILE__)
require File.expand_path('../../../app/services/distributions_service', __FILE__)

task :update_order_number => :environment do
  puts "run task :update_order_number at: #{Time.now}!"
  OrdersService.update_order_number
end