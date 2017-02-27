class ComputesService < BaseService
  def create_compute(compute_params)
    case compute_params["category"]
    when Settings.COMPUTE.CATEGORY.TEAM_SETMEAL
        plans = self.compute_team_setmeal(compute_params["params"])
        CommonService.response_format(ResponseCode.COMMON.OK, plans)
    else
      CommonService.response_format(ResponseCode.COMMON.FAILED, "ERROR: params is invalid!")
    end
  end

  def compute_team_setmeal(compute_params)
    plans = []

    # 参数合法性检查
    if compute_params["money"].blank? || compute_params["number"].blank?
      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           %Q{ ERROR: params money: #{compute_params[:money]}
                                               or number:#{compute_params[:number].inspect} is blank!})
    end

    # 遍历所有在售水果种类，计算每种水果满足当前人数的数量和金额。SINGLE商品，按个计算。TINY,BIG商品根据cms预设区间计算。
    # products = ProductsService.get_products_no_count(Product.where(is_deleted: false))
    products = Product.where(is_deleted: false)
    products.each do |product|
      # 根据商品价格规格计算满足当前人数的所需要的数量和价格

      # 先遍历该商品所有的团队套餐推荐策略
      product.compute_strategies.where(classify: Settings.COMPUTE.CATEGORY.TEAM_SETMEAL).each do |compute_strategy|
        # 根据平均每人食量单位分别计算每个计算策略所需总量和总金额
        single_product_plan = self.compute_quantity_price(product,
                                                          compute_params[:money],
                                                          compute_params[:number],
                                                          compute_strategy)
        plans << single_product_plan if !single_product_plan.blank?
      end
    end

    # 组合所有水果种类，并按照总价格,合理的组合水果种类，库存进行过滤，选出满足条件的方案。
    total_plans = []
    for i in 1..plans.size
      total_plans += plans.combination(i).to_a
    end

    # 计算组合推荐项的总金额
    total_plans.map! do |plan|
      total_price = 0.0
      plan.collect{|item| total_price += item["price"]}
      {"plans" => plan , "total_plans" => total_price}
    end

    # 过滤无效推荐项
    total_plans.select!{|plan| plan["total_plans"].to_f < compute_params[:money].to_f + compute_params[:money].to_f * 0.3}
  end

  def compute_quantity_price(product, money, number, compute_strategy)
    data = compute_strategy.as_json
    data["product"] = product.name
    data["quantity"] = compute_strategy.average_quantity * number
    # 根据设置的计量规格，查找对应规格的商品价格。
    if (price = product.prices.where(unit: compute_strategy.average_unit).first).blank?
      return nil
    end
    data["price"] = data["quantity"].to_f * price.real_price
    data["price"].to_f > money.to_f ? nil : data
  end

end
