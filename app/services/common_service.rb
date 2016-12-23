require 'csv'

class CommonService < BaseService
  def self.response_format(response_code, data=nil)
    response = response_code.as_json
    data.nil? ? response : response[:data] = data
    response
  end

  def self.import_products
    puts "import_products"
    picture_category = {"1" => 1,
                        "2" => 1,
                        "3" => 1,
                        "4" => 2,
                        "5" => 4,
                        "6" => 3,
                        "7" => 3,
                        "8" => 3,
                        "9" => 3,
                        "10" => 3}

    store = Store.find_by(name: "环球捕手")
    CSV.foreach("/var/www/eshop/products.csv") do |row|
      # begin
        Product.transaction do
          # 读取数据rows
          if !row.nil? && row[0] =~ /^\d+$/
            p row
            # # 数据库创建商品
            # product_params = {
            #   "uuid"=> SecureRandom.hex,
            #   "name"=> row[1],
            #   "description"=> row[2],
            #   "detail"=> row[3],
            #   "stock"=> row[4],
            #   "price"=> row[5],
            #   "real_price"=> row[6],
            #   "category_id"=> row[7]
            # }
            # product = store.products.create(product_params)
            # # 数据库创建商品图片
            # product_picture_dir = row[8].gsub(/\\/, '/')
            #
            # 遍历目录下的所有图片文件
            pictures_dir = "#{Rails.root}/public/images/huanqiubushou/products/#{product_picture_dir}"
            if File.directory?(pictures_dir)
              Dir.foreach(pictures_dir) do |filename|
                if filename =~ /(.*)(\d+)\.(jpg|png)$/
                  p filename
                  # # 解析图片分类
                  # picture_name = $1
                  # category_number = $2
                  # picture_params = {
                  #   "name"=> picture_name,
                  #   "url"=> filename.gsub("#{Rails.root}/public", ''),
                  #   "category"=> picture_category[category_number]
                  # }
                  # PicturesService.new.create_picture(product, picture_params)
                end
              end
            else
              raise "error: Product: #{row[1]} picture url is not directory!"
            end
          end
        end
      # rescue
      #   next
      # end
    end
  end
end