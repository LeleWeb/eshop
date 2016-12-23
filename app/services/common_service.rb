require 'csv'

class CommonService < BaseService
  def self.response_format(response_code, data=nil)
    response = response_code.as_json
    data.nil? ? response : response[:data] = data
    response
  end

  def self.import_products(file_path="/var/www/eshop/test.csv")
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

    CSV.foreach(file_path) do |row|
      begin
        Product.transaction do
          puts '1'*10, row
          # 读取数据rows
          if !row.nil? && row[0] =~ /^\d+&/
            puts '2'*10, row

            # 数据库创建商品
            store = Store.find_by(name: "环球捕手")
            puts '3'*10, store
            product_params = {
                "product"=> {
                    "uuid"=> SecureRandom.hex,
                    "name"=> row[1],
                    "description"=> row[2],
                    "detail"=> row[3],
                    "stock"=> row[4],
                    "price"=> row[5],
                    "real_price"=> row[6],
                    "category_id"=> row[7]
                }
            }
            puts '4'*10, product_params
            product = ProductsService.new.create_product(store, product_params)
            puts '5'*10, product
            # 数据库创建商品图片
            product_picture_dir = row[8].gsub(/\\/, '/')
            puts '6'*10, product_picture_dir

            # 遍历目录下的所有图片文件
            if File.directory?("#{Rails.root}/public/images/huanqiubushou/products/#{product_picture_dir}")
              puts '7'*10
              Dir.foreach(filepath) do |filename|
                if filename =~ /(.*)(\d+)\.(jpg|png)$/
                  puts '8'*10,filename

                  # 解析图片分类
                  picture_name = $1
                  category_number = $2
                  puts picture_name,category_number

                  picture_params = {
                      "picture"=> {
                          "name"=> picture_name,
                          "url"=> filename.gsub("#{Rails.root}/public", ''),
                          "category"=> picture_category[category_number],
                      },
                      "owner_id"=> product.id,
                      "owner_type"=> "Product"
                  }
                  puts product, picture_params
                  PicturesService.new.create_picture(product, picture_params)

                end
              end
            else
              raise "error: Product: #{row[1]} picture url is not directory!"
            end
          end
        end
      rescue
        next
      end
    end
  end
end