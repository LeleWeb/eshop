require 'csv'
require 'net/http'

class CommonService < BaseService
  def self.response_format(response_code, data=nil)
    response = response_code.as_json
    data.nil? ? response : response[:data] = data
    response
  end

  def self.import_products
    store = Store.find_by(name: "环球捕手")
    CSV.foreach("/var/www/eshop/products.csv") do |row|
      # begin
        Product.transaction do
          # 读取数据rows
          if !row.nil? && row[0] =~ /^\d+$/
            p row
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
            product = ProductsService.new.create_product(store, product_params)[:data]
            # 数据库创建商品图片
            product_picture_dir = row[8].gsub(/\\/, '/')
            # 遍历目录下的所有图片文件
            pictures_dir = "#{Rails.root}/public/images/huanqiubushou/products/#{product_picture_dir}"
            if File.directory?(pictures_dir)
              Dir.foreach(pictures_dir) do |filename|
                if filename =~ /(\d+)\.(jpg|png)$/
                  p filename
                  # 解析图片分类
                  category_number = $1.to_i
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
                    "url"=> "/images/huanqiubushou/products/#{product_picture_dir}/#{filename}",
                    "category"=> category_number
                  }
                  picture = PicturesService.new.create_picture(product, picture_params)
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

  def self.set_product_home
    # 获取前30个商品
    Product.limit(30).each do |product|
      CategoriesProduct.create(product_id: product.id, category_id: Settings.PRODUCT_CATEGORY.HOME)
    end
  end

  # http请求接口
  def self.post(url, params)
    p '4'*10,url, params
    uri = URI(url)
    p '5'*10,uri
    req = Net::HTTP::Post.new(uri)
    p '6'*10,req
    req.content_type = 'application/x-www-form-urlencoded'
    p '7'*10,req
    req.set_form_data(params)
    p '8'*10,req
    res = nil
    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      p '9'*10,http,req
      res = http.request(req)
      p '10'*10,res
    end
    p '10'*10,res,res.body
    res.body
    # case res
    #   when Net::HTTPSuccess, Net::HTTPRedirection
    #     res.body
    #   else
    #     res.value
    # end

    # uri = URI(url)
    # res = Net::HTTP.post_form(uri, params)
    # if res.is_a?(Net::HTTPSuccess)
    #   res.body
    # else
    #   nil
    # end
  end

end