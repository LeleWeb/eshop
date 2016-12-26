class DistributionRule < ApplicationRecord
  # 商家
  has_and_belongs_to_many :stores
end
