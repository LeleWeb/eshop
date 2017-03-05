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
    panic_buying = nil

    begin
      # 解析商品列表参数
      product_params = panic_buying_params.extract!("product_ids")["product_ids"]

      PanicBuying.transaction do
        # 创建限时抢购
        begin
          panic_buying = PanicBuying.create!(panic_buying_params)
        rescue Exception => e
          # TODO 创建限时抢购失败，打印对应log
          # "Error: create panic_buying failed! Details: #{e.backtrace.inspect} #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # 创建限时抢购与商品关联关系
        begin
          if !product_params.blank?
            panic_buying.products << Product.find(product_params)
          end
        rescue Exception => e
          # TODO 创建限时抢购与商品关联关系失败，打印对应log
          # "Error: create panic_buying products relation failed! Details: #{e.backtrace.inspect} #{e.message}"

          raise e
        end
      end
    rescue Exception => e
      # TODO 打印log
      # "Error: 新建限时抢购商品失败! Details: #{e.backtrace.inspect} #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED, "Error: 新建限时抢购商品失败!")
    end

    CommonService.response_format(ResponseCode.COMMON.OK, PanicBuyingsService.get_panic_buying(panic_buying))
  end

  def update_panic_buying(panic_buying, panic_buying_params)
    # 参数合法性检查
    if panic_buying.blank? || panic_buying_params.blank?
      return CommonService.response_format(ResponseCode.COMMON.FAILED,
      "ERROR: panic_buying: #{panic_buying} or panic_buying_params:#{panic_buying_params.inspect} is blank!")
    end

    begin
      # 解析商品列表参数
      product_params = panic_buying_params.extract!("product_ids")["product_ids"]

      PanicBuying.transaction do
        # 修改限时抢购
        begin
          panic_buying.update!(panic_buying_params)
        rescue Exception => e
          # TODO 更新限时抢购失败，打印对应log
          # "Error: update panic_buying failed! Details: #{e.backtrace.inspect} #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # 修改限时抢购与商品关联关系
        begin
          if !product_params.blank?
            # 先删除已有商品
            objs = panic_buying.products
            objs.clear if !objs.empty?

            # 新建参数传入的商品
            panic_buying.products << Product.find(product_params)
          end
        rescue Exception => e
          # TODO 修改限时抢购与商品关联关系失败，打印对应log
          # "Error: update panic_buying products relation failed! Details: #{e.backtrace.inspect} #{e.message}"

          # 继续向上层抛出异常
          raise e
        end
      end
    rescue Exception => e
      # TODO 打印log
      # "Error: 修改限时抢购商品失败! Details: #{e.backtrace.inspect} #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED, "Error: 修改限时抢购商品失败!")
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
