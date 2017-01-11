require File.expand_path('../../../app/services/base_service', __FILE__)
require File.expand_path('../../../app/services/common_service', __FILE__)

task :import_product_datas => :environment do
  puts "run task :import_product_datas at: #{Time.now}!"
  # cms完成之前，先使用脚本导入。
  CommonService.import_products
end

# 一次性设置数据库前30个商品为首页分类
task :set_product_home => :environment do
  puts "run task :set_product_home at: #{Time.now}!"
  # cms完成之前，先使用脚本实现。
  CommonService.set_product_home
end