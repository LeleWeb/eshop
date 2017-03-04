class PanicBuyingsService < BaseService
  def get_panic_buyings(query_params)
    panic_buyings = PanicBuying.where(is_deleted: false)
    total_count = nil

    # # 按照商品检索
    # if !query_params[:product].blank? && !(product = Product.find_by(id: query_params[:product])).nil?
    #   adverts = product.adverts
    # end
    #
    # # 按照广告分类检索
    # if !query_params[:category].blank?
    #   adverts = eval(adverts.nil? ? "Advert" : "adverts").where(category: query_params[:category])
    # end
    #
    # # 按照广告状态检索
    # if !query_params[:status].blank?
    #   adverts = eval(adverts.nil? ? "Advert" : "adverts").where(status: query_params[:status])
    # end

    # 如果存在分页参数,按照分页返回结果.
    if !query_params[:page].blank? && !query_params[:per_page].blank?
      panic_buyings = eval(panic_buyings.nil? ? "PanicBuying" : "panic_buyings").
                           where.(is_deleted: false).
                           page(query_params[:page]).
                           per(query_params[:per_page])
      total_count = panic_buyings.total_count
    else
      panic_buyings = panic_buyings.where(is_deleted: false)
      total_count = panic_buyings.size
    end

    CommonService.response_format(ResponseCode.COMMON.OK, PanicBuyingsService.get_panic_buyings(panic_buyings, total_count))
  end

  def get_panic_buying(panic_buying)
    # 参数合法性检查
    if panic_buying.blank?
      return CommonService.response_format(ResponseCode.COMMON.FAILED, "ERROR: panic_buying: #{panic_buying} is blank!")
    end

    CommonService.response_format(ResponseCode.COMMON.OK, PanicBuyingsService.get_panic_buying(panic_buying))
  end

  def create_panic_buying(panic_buying_params)
    product_params = nil
    advert_products = []

    # 参数合法性检查
    if panic_buying_params.blank?
      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "ERROR: panic_buying_params:#{panic_buying_params.inspect} is blank!")
    end

    # 解析商品列表参数
    product_params = panic_buying_params.extract!("product_ids")["product_ids"]

    # 创建广告
    panic_buying = PanicBuying.create(panic_buying_params)

    # 广告商品建立关联
    if !product_params.blank?
      panic_buying.products << Product.find(product_params)
    end

    CommonService.response_format(ResponseCode.COMMON.OK, PanicBuyingsService.get_panic_buying(panic_buying))
  end

  def update_panic_buying(panic_buying, panic_buying_params)
    product_params = nil
    advert_products = advert.products

    # 参数合法性检查
    if panic_buying.blank? || panic_buying_params.blank?
      return CommonService.response_format(ResponseCode.COMMON.FAILED,
      "ERROR: panic_buying: #{panic_buying} or panic_buying_params:#{panic_buying_params.inspect} is blank!")
    end

    # 解析商品价格参数
    product_params = panic_buying_params.extract!("product_ids")["product_ids"]

    # 更新商品信息
    panic_buying.update(panic_buying_params)

    # 如果有商品列表，则删除原来的商品列表，新增参数中的商品列表。
    if !product_params.blank?
      # 先删除已有商品
      panic_buying.products.clear

      # 新建参数传入的商品
      panic_buying.products << Product.find(product_params)
    end

    CommonService.response_format(ResponseCode.COMMON.OK, PanicBuyingsService.get_panic_buying(panic_buying))
  end

  def destroy_panic_buying(panic_buying, destroy_params)
    # 单个删除
    if !panic_buying.nil?
      panic_buying.update(is_deleted: true, deleted_at: Time.now)
    end

    # 批量删除
    if !destroy_params.blank?
      destroy_params.each do |panic_buying_id|
        object = PanicBuying.find_by(id: panic_buying_id)
        object.update(is_deleted: true, deleted_at: Time.now) if !object.nil?
      end
    end

    CommonService.response_format(ResponseCode.COMMON.OK)
  end

  # 格式化产品返回数据为指定格式
  def self.panic_buying_data_format(panic_buying, panic_buying_products)
    # 格式化返回数据
    panic_buying.as_json.merge("products" => panic_buying_products)
  end

  def self.get_panic_buyings(panic_buyings, total_count)
    data = panic_buyings.collect{|panic_buying| self.get_panic_buying(panic_buying)}
    {"total_count" => total_count.nil? ? panic_buyings.length : total_count, "panic_buyings" => data}
  end

  def self.get_panic_buying(panic_buying)
    self.panic_buying_data_format(panic_buying, ProductsService.get_products_no_count(panic_buying.products))
  end

end
