class AdvertsService < BaseService
  def get_adverts(query_params)
    adverts = Advert.where.not(is_deleted: true)
    total_count = nil

    # 按照商品检索
    if !query_params[:product].blank? && !(product = Product.find_by(id: query_params[:product])).nil?
      adverts = product.adverts
    end

    # 按照广告分类检索
    if !query_params[:category].blank?
      adverts = eval(adverts.nil? ? "Advert" : "adverts").where(category: query_params[:category])
    end

    # 按照广告状态检索
    if !query_params[:status].blank?
      adverts = eval(adverts.nil? ? "Advert" : "adverts").where(status: query_params[:status])
    end

    # 如果存在分页参数,按照分页返回结果.
    if !query_params[:page].blank? && !query_params[:per_page].blank?
      adverts = eval(adverts.nil? ? "Advert" : "adverts").
                where.not(is_deleted: true).
                page(query_params[:page]).
                per(query_params[:per_page])
      total_count = adverts.total_count
    else
      adverts = adverts.where.not(is_deleted: true)
      total_count = adverts.size
    end

    CommonService.response_format(ResponseCode.COMMON.OK, AdvertsService.get_adverts(adverts, total_count))
  end

  def get_advert(advert)
    # 参数合法性检查
    if advert.blank?
      return CommonService.response_format(ResponseCode.COMMON.FAILED, "ERROR: advert: #{advert} is blank!")
    end

    CommonService.response_format(ResponseCode.COMMON.OK, AdvertsService.get_advert(advert))
  end

  def create_advert(advert_params)
    puts __FILE__,__LINE__,__method__,%Q{params:
                                         advert_params: #{advert_params.inspect}}

    advert = nil

    # 参数合法性检查
    if advert_params.blank?
      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "ERROR: advert_params:#{advert_params.inspect} is blank!")
    end

    begin
      # 解析商品列表参数
      product_params = advert_params.extract!("product_ids")

      Advert.transaction do
        # 创建广告
        begin
          advert = Advert.create!(advert_params)
        rescue Exception => e
          # TODO 创建广告失败，打印对应log
          puts "Error: create advert failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # 广告与商品建立关联
        begin
          if !product_params.blank?
            advert.products << Product.find(product_params["product_ids"]).map!{|x| x.update(property: Settings.PRODUCT_PROPERTY.ADVERT_PRODUCT)}
          end
        rescue Exception => e
          # TODO 广告与商品建立关联失败，打印对应log
          puts "Error: create advert and product relation failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

      end
    rescue Exception => e
      # TODO 打印log
      puts "Error: 创建广告失败! Details: #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED, "Error: 创建广告失败!")
    end

    CommonService.response_format(ResponseCode.COMMON.OK, AdvertsService.get_advert(advert))
  end

  def update_advert(advert, advert_params)
    puts __FILE__,__LINE__,__method__,%Q{params:
                                         advert: #{advert.inspect},
                                         advert_params: #{advert_params.inspect}}

    # 参数合法性检查
    if advert.blank? || advert_params.blank?
      return CommonService.response_format(ResponseCode.COMMON.FAILED,
      "ERROR: advert: #{advert} or advert_params:#{advert_params.inspect} is blank!")
    end

    begin
      # 解析商品列表参数
      product_params = advert_params.extract!("product_ids")["product_ids"]

      PanicBuying.transaction do
        # 更新广告信息
        begin
          advert.update!(advert_params)
        rescue Exception => e
          # TODO 更新广告失败，打印对应log
          puts "Error: update advert failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # 如果有商品列表，则删除原来的商品列表，新增参数中的商品列表。
        begin
          if !product_params.blank?
            # 先删除已有商品
            advert.products.clear

            # 商品与广告关联
            advert.products << Product.find(product_params)
          end
        rescue Exception => e
          # TODO 修改用户收货地址失败，打印对应log
          puts "Error: update advert and product relation failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end
      end
    rescue Exception => e
      # TODO 打印log
      puts "Error: 修改广告失败! Details: #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED, "Error: 修改广告失败!")
    end

    CommonService.response_format(ResponseCode.COMMON.OK, AdvertsService.get_advert(advert))
  end

  def destroy_advert(advert, destroy_params)
    puts __FILE__,__LINE__,__method__,%Q{params:
                                         advert: #{advert.inspect},
                                         destroy_params: #{destroy_params.inspect}}

    begin
      PanicBuying.transaction do
        # 删除广告
        begin
          advert.update!(is_deleted: true, deleted_at: Time.now)
        rescue Exception => e
          # TODO 删除广告失败，打印对应log
          puts "Error: destroy advert failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # 删除广告与商品关联关系
        begin
          if destroy_params["products_delete"] == true
            # 需要删除广告对应的商品
            advert.products.map{|x| x.update!(is_deleted: true, deleted_at: Time.now)}
          else
            # 不删除广告对应的商品(必须将其改为普通商品)
            advert.products.map{|x| x.update!(property: Settings.PRODUCT_PROPERTY.COMMON_PRODUCT)}
          end
        rescue Exception => e
          # TODO 删除广告失败，打印对应log
          puts "Error: destroy advert failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end
      end
    rescue Exception => e
      # TODO 打印log
      puts "Error: 删除广告失败! Details: #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED, "Error: 删除广告失败!")
    end

    CommonService.response_format(ResponseCode.COMMON.OK)
  end

  # 格式化产品返回数据为指定格式
  def self.advert_data_format(advert, advert_products)
    documents = []

    # 获取广告图片
    advert.images.each do |image|
      documents += image.documents
    end

    # 格式化返回数据
    advert.as_json.merge("products" => advert_products,
                         "pictures" => documents)
  end

  def self.get_adverts(adverts, total_count)
    data = adverts.collect{|advert| self.get_advert(advert)}
    {"total_count" => total_count.nil? ? adverts.length : total_count, "adverts" => data}
  end

  def self.get_advert(advert)
    self.advert_data_format(advert, ProductsService.get_products_no_count(advert.products.where(property: Settings.PRODUCT_PROPERTY.ADVERT_PRODUCT)))
  end

end
