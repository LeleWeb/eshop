class PanicBuying < ApplicationRecord
  # 限时抢购
  has_and_belongs_to_many :products

  # 模型层数据验证
  validates :begin_time, :end_time, presence: true
  validates :is_deleted, inclusion: { in: [true, false] }
  validates :begin_time, :end_time, format: { with: /\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}/, message: "时间格式错误" }
end
