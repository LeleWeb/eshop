class DistributionsService < BaseService
  def create_distribution(store, distribution_params)
    # 获取父子节点对象
    parent = eval(distribution_params[:parent_type]).find(distribution_params[:parent_id])
    distributor_parent = Distribution.find_by(owner_type: distribution_params[:parent_type],
                                              owner_id: distribution_params[:parent_id])
    owner = eval(distribution_params[:owner_type]).find(distribution_params[:owner_id])

    # 父子节点合法性检验
    if parent.nil? || owner.nil? || distributor_parent.nil?
      return false
    end

    # 判断当前用户是否已经是分销者，若是则返回提示。
    if DistributionsService.is_already_distributor?(distribution_params[:owner_type],
                                                    distribution_params[:owner_id])
      return false
    end

    # 判断是否满足当前设定的分销规则
    if !DistributionsService.distribution_rule_authenticate?(store,
                                                             distribution_params[:owner_type],
                                                             distribution_params[:owner_id])
      return false
    end

    # 创建分销管理关系
    Distribution.create_distribution_relation(distributor_parent,
                                              distribution_params[:owner_type],
                                              distribution_params[:owner_id])
  end

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
    sum = 0.0 # 总金额单位是元
    customer.orders.where(status: Settings.ORDER.STATUS.COMPLETED).each do |order|
      sum += order.pay_price
    end
    sum > distribution_rule.value.to_f
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

end