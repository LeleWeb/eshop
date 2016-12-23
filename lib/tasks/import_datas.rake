require File.expand_path('../../../app/services/base_service', __FILE__)
require File.expand_path('../../../app/services/common_service', __FILE__)

task :import_product_datas => :environment do
  puts "run task :import_product_datas at: #{Time.now}!"
  # cms完成之前，先使用脚本导入。
  p Store.all, Account.all
  CommonService.import_products
end