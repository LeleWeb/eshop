class CollectionsService < BaseService
  def get_collections(owner)
    collections = []
    if !owner.nil?
      collections = owner.shopping_collections
    end
    CommonService.response_format(ResponseCode.COMMON.OK, collections)
  end

  def get_collection(collection)
    CommonService.response_format(ResponseCode.COMMON.OK, collection)
  end

  def create_collection(owner, product, collection_params)
    collection = owner.shopping_collections.create(collection_params)
    collection.product = product
    CommonService.response_format(ResponseCode.COMMON.OK, collection)
  end

  def update_collection(collection, collection_params)
    if collection.update(collection_params)
      CommonService.response_format(ResponseCode.COMMON.OK, collection)
    else
      ResponseCode.COMMON.FAILED['message'] = collection.errors
      CommonService.response_format(ResponseCode.COMMON.FAILED)
    end
  end

  def destory_collection(collection)
    collection.destroy
    CommonService.response_format(ResponseCode.COMMON.OK)
  end

end