class Setting < ApplicationRecord
  has_and_belongs_to_many :products

  # 模型层数据验证
  validates :setting_type, :position, presence: true, on: :create
  validates :setting_type, inclusion: { in: [Settings.PRODUCT_STATUS.UNDERCARRIAGE,
                                       Settings.PRODUCT_STATUS.GROUNDING] }
  validates :position, inclusion: { in: [Settings.PRODUCT_STATUS.UNDERCARRIAGE,
                                       Settings.PRODUCT_STATUS.GROUNDING] }
  validates :is_deleted, inclusion: { in: [true, false] }, allow_nil: true

end
