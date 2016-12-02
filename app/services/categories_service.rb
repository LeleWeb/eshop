class CategoriesService < BaseService
  def get_categories
    CommonService.response_format(ResponseCode.COMMON.OK, category.root.self_and_descendants)
  end

  def get_category(category)
    CommonService.response_format(ResponseCode.COMMON.OK, category.self_and_descendants)
  end

  def create_category(category_params)
    category = Category.create!(:name => category_params[:name])

    if category_params[:type] == 'child'
      parent_category = Category.find(category_params[:parent_id])
      category.move_to_child_of(parent_category)
    end

    CommonService.response_format(ResponseCode.COMMON.OK, category)
  end

  def update_category(category, account_params)
    if category.update(account_params)
      CommonService.response_format(ResponseCode.COMMON.OK, category)
    else
      ResponseCode.COMMON.FAILED['message'] = category.errors
      CommonService.response_format(ResponseCode.COMMON.FAILED)
    end
  end

  def destory_category(category)
    category.destroy
    CommonService.response_format(ResponseCode.COMMON.OK)
  end

end