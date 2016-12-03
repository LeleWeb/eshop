class StoresService < BaseService
  def get_stores
    CommonService.response_format(ResponseCode.COMMON.OK, Store.all)
  end

  def get_store(store)
    CommonService.response_format(ResponseCode.COMMON.OK, store)
  end

  def create_store(store_params)
    store = Store.new(store_params)

    if store.save
      CommonService.response_format(ResponseCode.COMMON.OK, store)
    else
      ResponseCode.COMMON.FAILED.message = store.errors
      CommonService.response_format(ResponseCode.COMMON.FAILED)
    end
  end

  def update_store(store, store_params)
    if store.update(store_params)
      CommonService.response_format(ResponseCode.COMMON.OK, store)
    else
      ResponseCode.COMMON.FAILED['message'] = store.errors
      CommonService.response_format(ResponseCode.COMMON.FAILED)
    end
  end

  def destory_store(store)
    store.destroy
    CommonService.response_format(ResponseCode.COMMON.OK)
  end

end