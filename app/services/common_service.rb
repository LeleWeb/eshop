require 'csv'

class CommonService < BaseService
  def self.response_format(response_code, data=nil)
    response = response_code.as_json
    data.nil? ? response : response[:data] = data
    response
  end

  def self.import_products
    puts "import_products"

    store = Store.find_by(name: "环球捕手")
    CSV.foreach("/var/www/eshop/products.csv") do |row|
      puts row
      # begin
        Product.transaction do
          # 读取数据rows
          if !row.nil? && row[0] =~ /^\d+$/
            # 数据库创建商品
            category = {"3" => 7, "5" => 6, "6"=>8, "7"=>5, "8"=>3, "9"=>4}
            product_params = {
              "uuid"=> SecureRandom.hex,
              "name"=> row[1],
              "description"=> row[2],
              "detail"=> row[3],
              "stock"=> row[4],
              "price"=> row[5],
              "real_price"=> row[6],
              "category_id"=> category[row[7]]
            }
            # product = store.products.create(product_params)
            p 'c'*10,product_params
            product = ProductsService.new.create_product(store, product_params)["data"]
            # 数据库创建商品图片
            product_picture_dir = row[8].gsub(/\\/, '/')

            # 遍历目录下的所有图片文件
            pictures_dir = "#{Rails.root}/public/images/huanqiubushou/products/#{product_picture_dir}"
            if File.directory?(pictures_dir)
              Dir.foreach(pictures_dir) do |filename|
                puts '2',filename
                if filename =~ /([^_\d]+)_?(\d+)\.(jpg|png)$/
                  # 解析图片分类
                  picture_name = $1
                  category_number = $2.to_i
                  puts '3',category_number
                  if category_number <= 3
                    category_number = 1
                  elsif category_number == 4
                    category_number = 2
                  elsif category_number ==5
                    category_number = 4
                  elsif category_number >= 6
                    category_number = 3
                  end
                  picture_params = {
                    "name"=> filename,
                    "url"=> "/images/huanqiubushou/products/#{filename}",
                    "category"=> category_number
                  }
                  PicturesService.new.create_picture(product, picture_params)

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