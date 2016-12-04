class ProductsService < BaseService
  def get_products
    CommonService.response_format(ResponseCode.COMMON.OK, Product.all)
  end

  def get_product(product)
    # 获取商品分类
    cagetory = Category.find(product.category_id).name

    # 获取商品所有图片
    pictures = product.pictures

    CommonService.response_format(ResponseCode.COMMON.OK,
                                  product.as_json.merge("cagetory" => cagetory, "pictures" => pictures))
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

end