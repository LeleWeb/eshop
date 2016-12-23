class ProductsService < BaseService
  def get_products(store, query_params)
    if !query_params[:category].blank? && !query_params[:limit].blank?
      CommonService.response_format(ResponseCode.COMMON.OK,
                                    self.find_by_category(store, query_params))
    elsif !query_params[:search].blank?
      CommonService.response_format(ResponseCode.COMMON.OK,
                                    self.find_by_search(store, query_params))
    else
      CommonService.response_format(ResponseCode.COMMON.OK, Product.all)
    end
  end

  def get_product(product)
    CommonService.response_format(ResponseCode.COMMON.OK, ProductsService.find_product_data(product))
  end

  def create_product(store, product_params)
    product = store.products.create(product_params)

    # 创建产品详情
    product.product_details.create(product_params[:details])

    CommonService.response_format(ResponseCode.COMMON.OK, product)

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
    product.destroy
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
            products << ProductsService.find_product_data(product)
          end
          data << {:category => category.as_json.merge(:picture => category.pictures[0]),
                   :products => products}
        end
        data
      elsif query_params[:category].to_i == Settings.PRODUCT_CATEGORY.HOME
        # 返回30个商品
        data = []
        Product.limit(30).each do |product|
          data << ProductsService.find_product_data(product)
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

    def self.find_product_data(product)
      # 获取商品分类
      categories = product.categories

      # 获取商品所有图片,并按照产品图片分类展示.
      picture_data = {}
      pictures = product.pictures
      Settings.PICTURES_CATEGORY.PRODUCT.each do |key, value|
        picture_data[key] = pictures.where(category: value)
      end

      product.as_json.merge(:categories => categories, :pictures => picture_data)
    end

end