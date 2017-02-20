class ProductsService < BaseService
  def get_products(store, query_params)
    if !query_params[:category].blank? && !query_params[:limit].blank?
      CommonService.response_format(ResponseCode.COMMON.OK,
                                    self.find_by_category(store, query_params))
    elsif !query_params[:search].blank?
      CommonService.response_format(ResponseCode.COMMON.OK,
                                    self.find_by_search(store, query_params))
    else
      CommonService.response_format(ResponseCode.COMMON.OK, ProductsService.find_product_datas(store))
    end
  end

  def get_product(product, query_params)
    CommonService.response_format(ResponseCode.COMMON.OK, ProductsService.find_product_data(product, query_params[:customer_id]))
  end

  def create_product(store, product_params)
    p '0'*10,product_params
    # 参数合法性检查
    if store.blank? || product_params.blank?
      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "ERROR: store:#{store.inspect} or product_params:#{product_params.inspect} is blank!")
    end

    # 解析商品价格参数
    price_params = product_params.extract!("prices")

    # 创建产品
    product = store.products.create(product_params)
    product.categories << Category.find(product_params["category_id"])
    p '1'*10,price_params
    # 创建商品价格
    product_prices = product.prices.create(price_params)
    # price_params.each do |price|
    #   product_prices << product.prices.create(price)
    # end
    p '2'*10,product_prices
    CommonService.response_format(ResponseCode.COMMON.OK,
                                  ProductsService.product_data_format(product, product_prices))

    # CommonService.response_format(ResponseCode.COMMON.OK, product)

    # if product.save
    #   CommonService.response_format(ResponseCode.COMMON.OK, product)
    # else
    #   ResponseCode.COMMON.FAILED.message = product.errors
    #   CommonService.response_format(ResponseCode.COMMON.FAILED)
    # end
  end

  def update_product(product, product_params)
    if product.update(product_params)
      CommonService.response_format(ResponseCode.COMMON.OK, product)
    else
      ResponseCode.COMMON.FAILED['message'] = product.errors
      CommonService.response_format(ResponseCode.COMMON.FAILED)
    end
  end

  def destory_product(product)
    product.update(is_deleted: true)
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

    # 如果存在指定的用户,则判断用户是否收藏了该商品.
    is_collected = false
    customer = nil
    if !customer_id.blank? && !(customer = Customer.find_by(id: customer_id)).nil?
      collection = customer.collections.where(object_type: 'Product', object_id: product.id)
      is_collected = true if !collection.nil?
    end

    product.as_json.merge(:categories => categories,
                          :pictures => picture_data,
                          :is_collected => is_collected)
  end

  # 格式化产品返回数据为指定格式
  def self.product_data_format(product, product_price)
    product.as_json.merge("prices" => product_price)
  end

end
