class GroupBuying < ApplicationRecord
  # 模型层数据验证
  validates :product_id, :target_amount, :begin_time, :end_time, :limit_min, :limit_max, presence: true, on: :create
  validates :product_id, numericality: { only_integer: true, greater_than: 0 }
  validates :current_number, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :target_amount, :limit_min, :limit_max, numericality: { greater_than: 0 }
  validates :begin_time, :end_time, format: { with: /\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}/, message: "时间格式错误" }

end
