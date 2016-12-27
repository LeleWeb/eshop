class DistributionsService < BaseService
  def create_distribution(store, distribution_params)
    # 获取父子节点对象
    parent = eval(distribution_params[:parent_type]).find(distribution_params[:parent_id])
    owner = eval(distribution_params[:owner_type]).find(distribution_params[:owner_id])

    # 父子节点合法性检验
    if parent.nil? || owner.nil?
      return false
    end

    # 判断当前用户是否已经是分销者，若是则返回提示。
    if DistributionsService.is_already_distributor?(distribution_params[:owner_type],
                                                    distribution_params[:owner_id])
      return false
    end

    # 判断当前设定的分销规则
    if DistributionsService.distribution_rule_authenticate?(store)
      
    end

    # 创建分销管理关系

  end

  def self.distribution_rule_authenticate?(store)
    # 目前设置商家与分销规则的关联关系为一对一,获取当前商户设置的分销规则记录.
    distribution_rule = store.distribution_rules.first
    if distribution_rule.nil? || distribution_rule.category.blank?
      return false
    end

    # 分不同情况判断customer是否满足成为分销者
    case distribution_rule.category
      when Settings.DISTRIBUTION_RULES.ANYONE #无条件成为分销者
        true
      when Settings.DISTRIBUTION_RULES.RULE1    # 至少消费一笔后成为分销者
        self.rule_1(store)
      when Settings.DISTRIBUTION_RULES.RULE2    # 消费满足一定的上限后成为分销者
        self.rule_2(store)
      else
        false
    end
  end

  # 当前customer至少在指定商家消费一笔算法
  def self.rule_1(store)
    
  end

  # 当前customer消费满足一定的上限后成为分销者算法
  def self.rule_2(store)

  end

  def self.is_already_distributor?(object_type, object_id)

  end

end