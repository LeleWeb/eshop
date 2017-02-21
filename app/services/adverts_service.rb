class AdvertsService < BaseService
  def get_adverts(query_params)
    adverts = nil

    # 按照商品检索
    if !query_params[:product].blank? && !(product = Product.find_by(id: query_params[:product])).nil?
      adverts = product.adverts
    end

    # 按照广告分类检索
    if !query_params[:category].blank?
      adverts = eval(customers.nil? ? "Advert" : "adverts").where(category: query_params[:category])
    end

    # 按照广告状态检索
    if !query_params[:status].blank?
      adverts = eval(customers.nil? ? "Advert" : "adverts").where(status: query_params[:status])
    end

    # 如果存在分页参数,按照分页返回结果.
    total_count = nil
    if !query_params[:page].blank? && !query_params[:per_page].blank?
      adverts = eval(customers.nil? ? "Advert" : "adverts").
                page(query_params[:page]).
                per(query_params[:per_page])
      total_count = adverts.total_count
    end

    CommonService.response_format(ResponseCode.COMMON.OK,
    AdvertsService.get_adverts(adverts.nil? ? Advert.where.not(is_deleted: true) : adverts.where.not(is_deleted: true),
                               total_count))
  end

  def get_advert(advert)
    # 参数合法性检查
    if advert.blank?
      return CommonService.response_format(ResponseCode.COMMON.FAILED, "ERROR: advert: #{advert} is blank!")
    end

    CommonService.response_format(ResponseCode.COMMON.OK, AdvertsService.get_advert(advert))
  end

  def create_advert(advert_params)
    product_params = nil
    advert_products = []

    # 参数合法性检查
    if advert_params.blank?
      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "ERROR: advert_params:#{advert_params.inspect} is blank!")
    end

    # 解析商品列表参数
    product_params = advert_params.extract!("product_ids")

    # 创建广告
    advert = Advert.create(advert_params)
    
    # 广告商品建立关联
    if !product_params.blank?
      advert_products = advert.products << Product.find(product_params["product_ids"])
    end

    CommonService.response_format(ResponseCode.COMMON.OK,
                                  AdvertsService.advert_data_format(advert, advert_products))
  end

  def update_advert(advert, advert_params)
    product_params = nil
    advert_products = advert.products

    # 参数合法性检查
    if advert.blank? || advert_params.blank?
      return CommonService.response_format(ResponseCode.COMMON.FAILED,
      "ERROR: advert: #{advert} or advert_params:#{advert_params.inspect} is blank!")
    end

    # 解析商品价格参数
    product_params = advert_params.extract!("product_ids")

    # 更新商品信息
    advert.update(advert_params)

    # 如果有商品列表，则删除原来的商品列表，新增参数中的商品列表。
    if !product_params.blank?
      # 先删除已有商品
      advert.products.clear

      # 新建参数传入的商品
      advert_products = advert.products << Product.find(product_params["product_ids"])
    end

    CommonService.response_format(ResponseCode.COMMON.OK,
                                  AdvertsService.advert_data_format(advert, advert_products))
  end

  def destroy_advert(advert, destroy_params)
    # 单个删除
    if !advert.nil?
      advert.update(is_deleted: true, deleted_at: Time.now)
    end

    # 批量删除
    if !destroy_params.blank?
      destroy_params.each do |advert_id|
        object = Advert.find_by(id: advert_id)
        object.update(is_deleted: true, deleted_at: Time.now) if !object.nil?
      end
    end

    CommonService.response_format(ResponseCode.COMMON.OK)
  end

  # 格式化产品返回数据为指定格式
  def self.advert_data_format(advert, advert_products)
    advert.as_json.merge("products" => advert_products)
  end

  def self.get_adverts(adverts, total_count)
    data = adverts.collect{|advert| self.get_advert(advert)}
    {"total_count" => total_count.nil? ? adverts.length : total_count, "adverts" => data}
  end

  def self.get_advert(advert)
    self.advert_data_format(advert, advert.products)
  end

end
