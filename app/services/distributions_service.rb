class DistributionsService < BaseService
  def create_distribution(store, distribution_params)
    # 获取父节点对象.
    parent = eval(distribution_params[:parent_type]).find(distribution_params[:parent_id])
    distributor_parent = Distribution.find_by(owner_type: distribution_params[:parent_type],
                                              owner_id: distribution_params[:parent_id])

    # 若上级为商家且商家没有加入分销关系表时,新建商家为根分销节点.
    if distribution_params[:parent_type] == "Store" && distributor_parent.nil?
      distributor_parent = Distribution.create(owner_type: distribution_params[:parent_type],
                                               owner_id: distribution_params[:parent_id])
    end

    # 父子节点合法性检验.
    if parent.nil? || distributor_parent.nil?
      return {"code" => false, "message" => "parent is blank!"}
    end

    # 判断owner合法性.
    result = DistributionsService.distribute_authenticate(store, distribution_params)
    if result["code"] != true
      return result
    end

    # 创建分销管理关系.
    distribution = DistributionsService.create_distribution_relation(distributor_parent,
                                                                     distribution_params[:owner_type],
                                                                     distribution_params[:owner_id])
    CommonService.response_format(ResponseCode.COMMON.OK, distribution)
  end

  # 分销佣金余额计算方法.
  def get_commission(customer)
    CommonService.response_format(ResponseCode.COMMON.OK,
                                  {"commission" => DistributionsService.calculate_commission(customer)})
  end

  # 分销鉴权
  def get_distribute_authority(store, distribution_params)
    # 判断当前用户是否已经是分销者,若是则返回提示.
    code = DistributionsService.is_already_distributor?(distribution_params[:owner_type],
                                                        distribution_params[:owner_id])
    CommonService.response_format(ResponseCode.COMMON.OK, code)
  end

  ###

  def self.distribution_rule_authenticate?(store, owner_type, owner_id)
    # 判断customer合法性
    customer = Customer.find_by(id: owner_id)
    if owner_type != 'Customer' || customer.nil?
      return false
    end
    
    # 目前设置商家与分销规则的关联关系为一对一,获取当前商户设置的分销规则记录.
    distribution_rule = store.distribution_rules.first
    if distribution_rule.nil? || distribution_rule.category.blank?
      return false
    end

    # 分不同情况判断customer是否满足成为分销者
    case distribution_rule.category
      when Settings.DISTRIBUTION_RULES.ANYONE   # 无条件成为分销者
        true
      when Settings.DISTRIBUTION_RULES.RULE1    # 至少消费一笔后成为分销者
        self.rule_1(customer)
      when Settings.DISTRIBUTION_RULES.RULE2    # 消费满足一定的上限后成为分销者
        self.rule_2(customer, distribution_rule)
      else
        false
    end
  end

  # 当前customer至少在指定商家消费一笔算法
  def self.rule_1(customer)
    # 查询改用户在系统中的所有交易完成的订单
    customer.orders.where(status: Settings.ORDER.STATUS.COMPLETED).size > 1
  end

  # 当前customer消费满足一定的上限后成为分销者算法
  def self.rule_2(customer, distribution_rule)
    CustomersService.get_consume_total(customer) > distribution_rule.value.to_f
  end

  def self.is_already_distributor?(object_type, object_id)
    !Distribution.find_by(owner_type: object_type, owner_id: object_id).nil?
  end

  def self.create_distribution_relation(distributor_parent, owner_type, owner_id)
    # 创建分销者节点
    distributor = Distribution.create(owner_type: owner_type, owner_id: owner_id)
    # 建立父子关系
    distributor.move_to_child_of(distributor_parent)
    distributor
  end

  def self.calculate_commission(customer)
    distributors = []
    consume_sum = 0.0
    commission = 0.0

    # 1.去分销关系表(distributions)中查询指定customer节点及其三级子孙节点；
    customer_distribution_node = Distribution.find_by(owner_type: "Customer", owner_id: customer.id)
    first_node = true # 记录第一个根节点
    Distribution.each_with_level(customer_distribution_node.self_and_descendants) do |distribution, level|
      # 记录第一个元素（也就是指定查询的customer元素），以其作为起始的level
      if first_node == true
        begin_level = level
        end_level = begin_level.to_i + (Settings.DISTRIBUTION_LEVEL.to_i - 1)
        first_node = false
      end

      # 过滤三级内的分销者记录
      if level >= begin_level && level <= end_level
        distributors << distribution
      end
    end

    # 2.遍历第一步的集合，查询每个customer的消费总额，然后求和；
    distributors.each do |distribution|
      consume_sum += CustomersService.get_consume_total(Customer.find(distribution.owner_id))
    end

    # 3.去distribution_levels表找到第二布计算的总额所在区间等级记录，将总额*佣金系数得到个人佣金余额；
    distribution_level = DistributionLevel.where("minimum >= ? and maximum < ? ", consume_sum, consume_sum).first
    if !distribution_level.nil?
      commission = consume_sum*distribution_level.commission_ratio
    end
    commission.to_f
  end

  def self.distribute_authenticate(store, distribution_params)
    # 获取当前customre对象.
    owner = eval(distribution_params[:owner_type]).find(distribution_params[:owner_id])

    # customer节点合法性检验.
    if owner.nil?
      return {"code" => false, "message" => "ERROR: Customer id invalid!"}
    end

    # 判断当前用户是否已经是分销者,若是则返回提示.
    if DistributionsService.is_already_distributor?(distribution_params[:owner_type],
                                                    distribution_params[:owner_id])
      return {"code" => false, "message" => "ERROR: Customer is already distributor!"}
    end

    # 判断是否满足当前设定的分销规则.
    if !DistributionsService.distribution_rule_authenticate?(store,
                                                             distribution_params[:owner_type],
                                                             distribution_params[:owner_id])
      return {"code" => false, "message" => "ERROR: distribution rule authenticate failed!"}
    end

    return {"code" => true, "message" => "successful!"}
  end

  # 有用户订单完成时,需要触发计算以改用户为起点，往上两级的所有用户佣金，并刷新到消费者账户明细表.
  def self.update_customer_account_details(order)
    distributors = []

    # 判断该用户是否是分销者.
    result = DistributionsService.distribute_authenticate(Store.find_by(name: "环球捕手"),
                                                          {:owner_type => order.buyer_type, :owner_id => order.buyer_id})
    if result["code"] != true
      return
    end

    # 是合法分销者,查找该用户的分销记录。
    distributor = Distribution.find_by(owner_type: distribution_params[:parent_type],
                                       owner_id: distribution_params[:parent_id])
    if distributor.nil?
      return
    end

    # 计算自己和往上两级的父辈佣金,同时更新到消费者账户明细表。
    begin_level = distributor.level
    end_level = begin_level - (Settings.DISTRIBUTION_LEVEL-1)
    Distribution.each_with_level(distributor.self_and_ancestors) do |distribution, level|
      # 过滤三级内的分销者记录.
      if level <= begin_level && level >= end_level
        distributors << distribution
      end
    end

    # 计算每个分销者本次佣金,创建消费者账户明细表记录.
    distributors.each do |distributor|
      CustomerAccountDetail.create(customer_id: distributor.owner_id,
                                   trade_time: Time.now,
                                   expenses_receipts: order.pay_price,
                                   category: Settings.CUSTOMER_ACCOUNT.TRANSACTION_TYPE.COMMISSION)
    end

  end

end