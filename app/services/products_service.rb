class ProductsService < BaseService
  def get_products(store, query_params)
    LOG.info %Q{#{__FILE__},#{__LINE__},#{__method__},params:
                                                        store: #{store.inspect},
                                                        query_params: #{query_params.inspect} }

    # 是否按照查询类型检索
    if query_params["type"] == "home"
      return ProductsService.get_home_products(store, query_params["customer"])
    end

    products = store.products.where(is_deleted: false,
                                    status: Settings.PRODUCT_STATUS.UNDERCARRIAGE)
    total_count = nil

    # 按照产品分类检索
    if !query_params[:category].blank?
      products = eval(products.blank? ? "Product" : "products").where(category_id: query_params[:category])
    end

    # 按照产品属性检索
    if !query_params[:property].blank?
      products = eval(products.blank? ? "Product" : "products").where(property: query_params[:property])
    end

    # 按照产品产品名称关键字检索
    if !query_params[:search].blank?
      products = eval(products.blank? ? "Product" : "products").where("name LIKE :name",
                                                                      {name: "%#{query_params[:search]}%"})
    end

    # 如果存在分页参数,按照分页返回结果.
    if !query_params[:page].blank? && !query_params[:per_page].blank?
      products = eval(products.blank? ? "Product" : "products").
                      page(query_params[:page]).
                      per(query_params[:per_page])
      total_count = products.total_count
    else
      total_count = products.size
    end

    CommonService.response_format(ResponseCode.COMMON.OK, ProductsService.get_products(products, total_count))
    # if !query_params[:category].blank? && !query_params[:limit].blank?
    #   CommonService.response_format(ResponseCode.COMMON.OK,
    #                                 self.find_by_category(store, query_params))
    # elsif !query_params[:search].blank?
    #   CommonService.response_format(ResponseCode.COMMON.OK,
    #                                 self.find_by_search(store, query_params))
    # else
    #   CommonService.response_format(ResponseCode.COMMON.OK, ProductsService.find_product_datas(store))
    # end
  end

  def get_product(product, query_params)
    LOG.info %Q{#{__FILE__},#{__LINE__},#{__method__},params:
                                                        product: #{product.inspect},
                                                        query_params: #{query_params.inspect} }
    CommonService.response_format(ResponseCode.COMMON.OK, ProductsService.find_product_data(product, query_params[:customer]))
  end

  def create_product(store, product_params)
    LOG.info %Q{#{__FILE__},#{__LINE__},#{__method__},params:
                                                        store: #{store.inspect},
                                                        product_params: #{product_params.inspect} }

    product = nil

    begin
      # 解析参数
      begin
        group_buying = product_params.extract!("group_buying")["group_buying"]
        price_params = product_params.extract!("prices")["prices"]
        compute_strategy_params = product_params.extract!("compute_strategies")["compute_strategies"]
      rescue Exception => e
        # TODO 解析参数失败，打印对应LOG
        LOG.error "Error: file: #{__FILE__} line:#{__LINE__} params invalid! Details: #{e.message}"

        # 继续向上层抛出异常
        raise e
      end

      Product.transaction do
        # 创建产品
        begin
          product = store.products.create!(product_params)
          product.categories << Category.find(product_params["category_id"])
        rescue Exception => e
          # TODO 创建产品失败，打印对应LOG
          LOG.error "Error: file: #{__FILE__} line:#{__LINE__} create product failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # 创建商品价格
        begin
          if !price_params.blank?
            product.prices.create(price_params)
          end
        rescue Exception => e
          # TODO 创建商品价格失败，打印对应LOG
          LOG.error "Error: file: #{__FILE__} line:#{__LINE__} create product price failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # 创建商品计算策略
        begin
          if !compute_strategy_params.blank?
            product.compute_strategies.create(compute_strategy_params)
          end
        rescue Exception => e
          # TODO 创建商品计算策略失败，打印对应LOG
          LOG.error "Error: file: #{__FILE__} line:#{__LINE__} create product compute strategy failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # 创建商品团购数据
        begin
          if !group_buying.blank?
            product.create_group_buying!(group_buying)
          end
        rescue Exception => e
          # TODO 创建商品团购数据失败，打印对应LOG
          LOG.error "Error: file: #{__FILE__} line:#{__LINE__} create product group buying failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end
      end
    rescue Exception => e
      # TODO 打印LOG
      LOG.error "Error: file: #{__FILE__} line:#{__LINE__} 创建商品失败! Details: #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "Error: file: #{__FILE__} line:#{__LINE__} 创建商品失败! Details: #{e.message}")
    end

    CommonService.response_format(ResponseCode.COMMON.OK, ProductsService.product_data_format(product))
  end

  def update_product(product, product_params)
    LOG.info %Q{#{__FILE__},#{__LINE__},#{__method__},params:
                                                        product: #{product.inspect},
                                                        product_params: #{product_params.inspect} }

    begin
      # 解析参数
      begin
        price_params = product_params.extract!("prices")["prices"]
        compute_strategy_params = product_params.extract!("compute_strategies")["compute_strategies"]
        group_buying = product_params.extract!("group_buying")["group_buying"]
      rescue Exception => e
        # TODO 解析参数失败，打印对应LOG
        LOG.error "Error: file: #{__FILE__} line:#{__LINE__} params invalid! Details: #{e.message}"

        # 继续向上层抛出异常
        raise e
      end

      Product.transaction do
        # 更新商品信息
        begin
          product.update!(product_params)
        rescue Exception => e
          # TODO 修改商品失败，打印对应LOG
          LOG.error "Error: file: #{__FILE__} line:#{__LINE__} update product failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # 如果有价格列表，则删除原来的价格，新增参数中的价格。
        begin
          if !price_params.blank?
            # 先删除已有价格
            product.prices.map{|x| x.destroy }

            # 新建参数传入的价格
            product.prices.create!(price_params)
          end
        rescue Exception => e
          # TODO 更新商品价格失败，打印对应LOG
          LOG.error "Error: file: #{__FILE__} line:#{__LINE__} update product price failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # 如果有计算策略列表，则删除原来的计算策略，新增参数中的计算策略。
        begin
          if !compute_strategy_params.blank?
            # 先删除已有计算策略
            product.compute_strategies.map{|x| x.destroy }

            # 新建参数传入的计算策略
            product.compute_strategies.create!(compute_strategy_params)
          end
        rescue Exception => e
          # TODO 更新商品计算策略失败，打印对应LOG
          LOG.error "Error: file: #{__FILE__} line:#{__LINE__} update product compute strategy failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # 如果有团购数据，则删除原来的团购数据，新增参数中的团购数据。
        begin
          if !group_buying.blank?
            # 先删除已有计算策略
            obj = product.group_buying
            obj.destroy if !obj.nil?

            # 新建参数传入的计算策略
            product.create_group_buying(group_buying)
          end
        rescue Exception => e
          # TODO 更新商品团购数据失败，打印对应LOG
          LOG.error "Error: file: #{__FILE__} line:#{__LINE__} update product group buying failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end
      end
    rescue Exception => e
      # TODO 打印LOG
      LOG.error "Error: file: #{__FILE__} line:#{__LINE__} 更新商品失败! Details: #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "Error: file: #{__FILE__} line:#{__LINE__} 更新商品失败! Details: #{e.message}")
    end

    CommonService.response_format(ResponseCode.COMMON.OK, ProductsService.product_data_format(product))
  end

  def destroy_product(product, destroy_params)
    LOG.info %Q{#{__FILE__},#{__LINE__},#{__method__},params:
                                                        product: #{product.inspect},
                                                        destroy_params: #{destroy_params.inspect} }

    begin
      Product.transaction do
        # 删除商品本身
        begin
          product.update!(is_deleted: true, deleted_at: Time.now)
        rescue Exception => e
          # TODO 删除商品失败，打印对应LOG
          LOG.error "Error: file: #{__FILE__} line:#{__LINE__} destroy product failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # 删除产品价格
        begin
          product.prices.each {|price| price.update!(is_deleted: true, deleted_at: Time.now)}
        rescue Exception => e
          # TODO 删除产品价格失败，打印对应LOG
          LOG.error "Error: file: #{__FILE__} line:#{__LINE__} destroy product prices failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # 删除产品计算策略
        begin
          product.compute_strategies.each {|compute_strategy| compute_strategy.update!(is_deleted: true, deleted_at: Time.now)}
        rescue Exception => e
          # TODO 删除产品计算策略失败，打印对应LOG
          LOG.error "Error: file: #{__FILE__} line:#{__LINE__} destroy product compute strategies failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # 删除产品团购数据
        begin
          product.group_buying.update!(is_deleted: true, deleted_at: Time.now) if !product.group_buying.nil?
        rescue Exception => e
          # TODO 删除产品团购数据失败，打印对应LOG
          LOG.error "Error: file: #{__FILE__} line:#{__LINE__} destroy product group buying failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # 批量删除
        begin
          if !destroy_params.blank?
            destroy_params.each do |product_id|
              Product.find(product_id).update!(is_deleted: true, deleted_at: Time.now)
            end
          end
        rescue Exception => e
          # TODO 批量删除商品失败，打印对应LOG
          LOG.error "Error: file: #{__FILE__} line:#{__LINE__} destroy mutli product failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

      end
    rescue Exception => e
      # TODO 打印LOG
      LOG.error "Error: file: #{__FILE__} line:#{__LINE__} 删除商品失败! Details: #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "Error: file: #{__FILE__} line:#{__LINE__} 删除商品失败! Details: #{e.message}")
    end

    CommonService.response_format(ResponseCode.COMMON.OK)
  end

  # private

    def find_by_category(store, query_params)
      if query_params[:category] == 'all'
        data = []
        # 查询商家所有分类
        product_ids = store.products.collect{|product| product.id}.uniq
        category_ids = CategoriesProduct.where("product_id in (?)", product_ids).group("category_id").collect{|x| x.category_id}
        Category.find(category_ids).each do |category|
          products = []
          category.products.each do |product|
            products << ProductsService.find_product_data(product) if !product.nil?
          end
          data << {:category => category.as_json.merge(:picture => category.pictures[0]),
                   :products => products}
        end
        data
      elsif query_params[:category].to_i == Settings.PRODUCT_CATEGORY.HOME
        # # 返回30个商品
        # data = []
        # apples = Product.where("name = ? or name = ?", "阿克苏苹果", "夏威夷果").limit(6)
        # jianguo = Product.where(name: "巴旦木").limit(6)
        # hongzao = Product.where(name: "红枣").limit(6)
        # heijialun = Product.where(name: "黑加仑葡萄干").limit(6)
        # hetao = Product.where(name: "美国核桃").limit(6)
        #
        # for i in 0..5
        #   data << ProductsService.find_product_data(apples[i])
        #   data << ProductsService.find_product_data(jianguo[i])
        #   data << ProductsService.find_product_data(hongzao[i])
        #   data << ProductsService.find_product_data(heijialun[i])
        #   data << ProductsService.find_product_data(hetao[i])
        # end

        data = []
        category = Category.find_by(id: Settings.PRODUCT_CATEGORY.HOME)
        products = category.products
        temp = products[1,products.length]
        temp << products[0]
        temp.each do |product|
          data << ProductsService.find_product_data(product)
        end
        data
      else
        # 按照分类查询产品
        data = []
        category = Category.find_by(id: query_params[:category].to_i)
        if !category.nil?
          category.products.each do |product|
            data << ProductsService.find_product_data(product)
          end
        end
        data
      end
    end

    def find_by_search(store, query_params)
      data = []
      store.products.where("name like ?", "%#{query_params[:search]}%").each do |product|
        data << ProductsService.find_product_data(product)
      end
      data
    end

  def self.find_product_datas(store)
    data = []
    store.products.where(is_deleted: false).each do |product|
      data << ProductsService.find_product_data(product)
    end
    data
  end
  
  # 根据product id查询商品信息
  def self.find_by_id(product_id)
    product = Product.find_by(id: product_id)

    if !product.nil?
      product = self.find_product_data(product)
    end

    product
  end

  def self.find_product_data(product, customer_id=nil)
    data = nil

    if product.nil?
      return nil
    end

    # 获取商品分类
    categories = product.categories

    # 获取商品所有图片,并按照产品图片分类展示.
    picture_data = {}
    pictures = product.images
    Settings.PICTURES_CATEGORY.PRODUCT.each do |key, value|
      documents = []
      pictures.where(category: value).each do |image|
        documents += image.documents
      end
      picture_data[value] = documents #pictures.where(category: value).collect{|image| image.as_json.merge(:pictures => image.documents)}
    end

    # 如果存在指定的用户,处理收藏和首页商品已经添加购物车功能.
    is_collected = false
    shopping_cart = nil
    if !customer_id.blank? && !(customer = Customer.find_by(id: customer_id)).nil?
      # 如果存在指定的用户,则判断用户是否收藏了该商品.
      collection = customer.collections.where(object_type: 'Product', object_id: product.id)
      is_collected = true if !collection.nil?

      # 首页商品已经添加购物车项时进行关联
    shopping_cart = ShoppingCart.where(is_deleted: false,
                                       property: Settings.CART_OR_ITEM.PROPERTY.CART_ITEM,
                                       owner_type: 'Customer',
                                       owner_id: customer_id,
                                       product_id: product.id).first
    end

    # 添加价格属性
    product_data = ProductsService.product_data_format(product)

    product_data.merge(:categories => categories,
                       :pictures => picture_data,
                       :is_collected => is_collected,
                       :shopping_cart => shopping_cart)
  end

  # 格式化产品返回数据为指定格式
  def self.product_data_format(product)
    product.as_json.merge("prices" => product.prices,
                          "compute_strategies" => product.compute_strategies,
                          "group_buying" => product.group_buying)
  end

  def self.get_products(products, total_count)
    # products.collect{|product| self.find_product_data(product)}

    data = products.collect{|product| self.find_product_data(product)}
    {"total_count" => total_count.nil? ? products.length : total_count, "products" => data}
  end

  def self.get_products_no_count(products, customer_id=nil)
    products.collect{|product| self.find_product_data(product, customer_id)}
  end

  def self.get_home_products(store, customer_id)
    home_adverts = []

    # 首页广告及其关联的商品数据
    adverts = Advert.where(category: Settings.ADVERT.CATEGORY.HOME_TOP,
                           status: Settings.ADVERT.STATUS.PUTTING,
                           is_deleted: false)
    adverts.each do |advert|
      home_adverts << {"advert" => AdvertsService.get_advert(advert),
                       "products" => AdvertsService.get_advert_products(advert, customer_id)}
    end

    # 限时抢购商品(根据限时抢购是否处于有效状态返回当前的限时抢购商品列表)
    now = Time.now
    panic_buying_products = []
    panic_buying = PanicBuying.where("is_deleted = ? AND begin_time <= ? AND end_time >= ? ", false, now, now).first
    panic_buying_products = self.get_products_no_count(panic_buying.products) if !panic_buying.nil?

    # 查询团队套餐
    team_setmeal = []
    Product.where(category_id: Settings.PRODUCT_CATEGORY.TEAM_SETMEAL, is_deleted: false).each do |product|
      team_setmeal << self.find_product_data(product)
    end

    # # 首页商品列表数据(按照以下分类组织：单品，果切，团购商品)
    # # home_products = self.get_products_no_count(store.products.where(property: Settings.PRODUCT_PROPERTY.COMMON_PRODUCT, is_deleted: false))
    # home_products = self.get_home_products_by_category

    # 首页商品按照广告组织
    home_products = []
    product_adverts = Advert.where(category: Settings.ADVERT.CATEGORY.HOME_PRODUCT,
                                   status: Settings.ADVERT.STATUS.PUTTING,
                                   is_deleted: false)
    product_adverts.each do |advert|
      home_products << {"advert" => AdvertsService.get_advert(advert, customer_id)}
    end

    # 购物车项
    carts = CartsService.get_customer_carts(customer_id)

    # 组织输出首页数据
    {"adverts" => home_adverts,
     "panic_buying" => !panic_buying.nil? ? panic_buying.as_json.merge("products" => panic_buying_products) : nil,
     "team_setmeal" => team_setmeal,
     "products"=> home_products,
     "customer_carts"=> carts}
  end

  # 用户购买团购商品后，自动更新团购商品的数据接口。
  def self.update_product_data(order)
    group_buying_products = order.products.where(property: Settings.PRODUCT_PROPERTY.GROUP_PRODUCT)
    group_buying_products.each do |product|
      # 获取该商品对应的订单详情项
      order_detail = order.shopping_carts.where(product_id: product.id).first

      # 团购
      group_buying = product.group_buying
      if !group_buying.blank?
        current_amount = group_buying.current_amount + order_detail.amount
        product.group_buying.update(current_number: group_buying.current_number+1,
                                    completion_rate: current_amount/group_buying.target_amount,
                                    current_amount: current_amount)
      end
    end
  end

  # 查询首页商品列表数据(按照以下分类组织：单品，果切，团购商品)
  def self.get_home_products_by_category
    single_setmeal = []
    personal_setmeal= []
    group_buyings = []

    # 查询单品
    Setting.where(setting_type: Settings.SETTING.HOME_PRODUCT.VALUE,
                  position: Settings.SETTING.HOME_PRODUCT.SINGLE_SETMEAL,
                  is_deleted: false).each do |item|
      single_setmeal = self.get_products_no_count(item.products)
    end

    # 查询果切
    Setting.where(setting_type: Settings.SETTING.HOME_PRODUCT.VALUE,
                  position: Settings.SETTING.HOME_PRODUCT.PERSONAL_SETMEAL,
                  is_deleted: false).each do |item|
      personal_setmeal = self.get_products_no_count(item.products)
    end

    # 团购商品
    now = Time.now
    Setting.where(setting_type: Settings.SETTING.HOME_PRODUCT.VALUE,
                  position: Settings.SETTING.HOME_PRODUCT.GROUP_PRODUCT,
                  is_deleted: false).each do |item|
      item.products.each do |product|
        if product.group_buying.is_deleted == false &&
            product.group_buying.begin_time <= now &&
            product.group_buying.end_time >= now
          group_buyings << self.find_product_data(product)
        end
      end
    end

    # # 团购商品
    # now = Time.now
    # GroupBuying.where("is_deleted = ? AND begin_time <= ? AND end_time >= ? ",
    #                   false,
    #                   now,
    #                   now).each do |group_buying|
    #   product = Product.find_by(id: group_buying.product_id)
    #   group_buyings << group_buying.as_json.merge("product" => self.find_product_data(product))
    # end

    {"single_setmeal" => single_setmeal,
     "personal_setmeal"=> personal_setmeal,
     "group_buyings" => group_buyings}
  end

end
