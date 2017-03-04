class PanicBuying < ApplicationRecord
  # 限时抢购
  has_and_belongs_to_many :products
end
