class AdvertsService < BaseService
  def get_adverts(store, query_params)
    if !query_params[:category].blank? && !query_params[:limit].blank?
      CommonService.response_format(ResponseCode.COMMON.OK,
                                    self.find_by_category(store, query_params))
    elsif !query_params[:search].blank?
      CommonService.response_format(ResponseCode.COMMON.OK,
                                    self.find_by_search(store, query_params))
    else
      CommonService.response_format(ResponseCode.COMMON.OK, AdvertsService.find_advert_datas(store))
    end
  end

  def get_advert(advert, query_params)
    CommonService.response_format(ResponseCode.COMMON.OK, AdvertsService.find_advert_data(advert, query_params[:customer_id]))
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

  def destory_advert(advert)
    advert.update(is_deleted: true)
    CommonService.response_format(ResponseCode.COMMON.OK)
  end

  # private

    def find_by_category(store, query_params)
      if query_params[:category] == 'all'
        data = []
        # 查询商家所有分类
        advert_ids = store.adverts.collect{|advert| advert.id}.uniq
        category_ids = Categoriesadvert.where("advert_id in (?)", advert_ids).group("category_id").collect{|x| x.category_id}
        Category.find(category_ids).each do |category|
          adverts = []
          category.adverts.each do |advert|
            adverts << AdvertsService.find_advert_data(advert) if !advert.nil?
          end
          data << {:category => category.as_json.merge(:picture => category.pictures[0]),
                   :adverts => adverts}
        end
        data
      elsif query_params[:category].to_i == Settings.advert_CATEGORY.HOME
        # # 返回30个商品
        # data = []
        # apples = advert.where("name = ? or name = ?", "阿克苏苹果", "夏威夷果").limit(6)
        # jianguo = advert.where(name: "巴旦木").limit(6)
        # hongzao = advert.where(name: "红枣").limit(6)
        # heijialun = advert.where(name: "黑加仑葡萄干").limit(6)
        # hetao = advert.where(name: "美国核桃").limit(6)
        #
        # for i in 0..5
        #   data << AdvertsService.find_advert_data(apples[i])
        #   data << AdvertsService.find_advert_data(jianguo[i])
        #   data << AdvertsService.find_advert_data(hongzao[i])
        #   data << AdvertsService.find_advert_data(heijialun[i])
        #   data << AdvertsService.find_advert_data(hetao[i])
        # end

        data = []
        category = Category.find_by(id: Settings.advert_CATEGORY.HOME)
        adverts = category.adverts
        temp = adverts[1,adverts.length]
        temp << adverts[0]
        temp.each do |advert|
          data << AdvertsService.find_advert_data(advert)
        end
        data
      else
        # 按照分类查询产品
        data = []
        category = Category.find_by(id: query_params[:category].to_i)
        if !category.nil?
          category.adverts.each do |advert|
            data << AdvertsService.find_advert_data(advert)
          end
        end
        data
      end
    end

    def find_by_search(store, query_params)
      data = []
      store.adverts.where("name like ?", "%#{query_params[:search]}%").each do |advert|
        data << AdvertsService.find_advert_data(advert)
      end
      data
    end

  def self.find_advert_datas(store)
    data = []
    store.adverts.where(is_deleted: false).each do |advert|
      data << AdvertsService.find_advert_data(advert)
    end
    data
  end
  
  # 根据advert id查询商品信息
  def self.find_by_id(advert_id)
    advert = advert.find_by(id: advert_id)

    if !advert.nil?
      advert = self.find_advert_data(advert)
    end

    advert
  end

  def self.find_advert_data(advert, customer_id=nil)
    if advert.nil?
      return nil
    end

    # 获取商品分类
    categories = advert.categories

    # 获取商品所有图片,并按照产品图片分类展示.
    picture_data = {}
    pictures = advert.images
    Settings.PICTURES_CATEGORY.advert.each do |key, value|
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
      collection = customer.collections.where(object_type: 'advert', object_id: advert.id)
      is_collected = true if !collection.nil?
    end

    advert.as_json.merge(:categories => categories,
                          :pictures => picture_data,
                          :is_collected => is_collected)
  end

  # 格式化产品返回数据为指定格式
  def self.advert_data_format(advert, advert_products)
    advert.as_json.merge("products" => advert_products)
  end

end
