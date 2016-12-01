class CategoriesService < BaseService
  def get_categories
    CommonService.response_format(ResponseCode.COMMON.OK, Account.all)
  end

  def get_category(account)
    CommonService.response_format(ResponseCode.COMMON.OK, account)
  end

  def create_category(category_params)
    category = Category.create!(:name => category_params[:name])

    if category_params[:type] == 'child'
      parent_category = Category.find(category_params[:parent_id])
      category.move_to_child_of(parent_category)
    end

    CommonService.response_format(ResponseCode.COMMON.OK, category)
  end

  def update_category(account, account_params)
    if account.update(account_params)
      CommonService.response_format(ResponseCode.COMMON.OK, account)
    else
      ResponseCode.COMMON.FAILED['message'] = account.errors
      CommonService.response_format(ResponseCode.COMMON.FAILED)
    end
  end

  def destory_category(account)
    account.destroy
    CommonService.response_format(ResponseCode.COMMON.OK)
  end

end