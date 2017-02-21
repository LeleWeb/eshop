class ComputesService < BaseService
  def create_compute(compute_params)
    case compute_params[:category]
    when Settings.COMPUTE.CATEGORY.TEAM_SETMEAL
        compute_team_setmeal(compute_params[:params])
    else
      CommonService.response_format(ResponseCode.COMMON.FAILED, "ERROR: params is invalid!")
    end
  end

  def compute_team_setmeal(compute_params)
    # 参数合法性检查
    if compute_params[:money].blank? || compute_params[:number].blank?
      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           %Q{ ERROR: params money: #{compute_params[:money]}
                                               or number:#{compute_params[:number].inspect} is blank!})
    end

    # 遍历所有在售水果种类，计算每种水果满足当前人数的数量和金额。SINGLE商品，按个计算。TINY,BIG商品根据cms预设区间计算。


    # 组合所有水果种类，并按照总价格,合理的组合水果种类，库存进行过滤，选出满足条件的方案。


  end

end
