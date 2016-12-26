class DistributionsService < BaseService
  def create_distribution(store, distribution_params)
    # 判断当前设定的分销规则
    if DistributionsService.distribution_authenticate(store)
      
    end

    # 创建分销管理关系

  end

  def self.distribution_authenticate(store)

  end

end