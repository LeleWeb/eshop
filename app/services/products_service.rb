class ProductsService < BaseService
  def get_products
    CommonService.response_format(ResponseCode.COMMON.OK, Product.all)
  end

  def get_product(product)
    CommonService.response_format(ResponseCode.COMMON.OK, product)
  end

  def create_product(store, product_params)
    product = store.build_products(product_params)

    if product.save
      CommonService.response_format(ResponseCode.COMMON.OK, product)
    else
      ResponseCode.COMMON.FAILED.message = product.errors
      CommonService.response_format(ResponseCode.COMMON.FAILED)
    end
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