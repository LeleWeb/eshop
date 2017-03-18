class Setting < ApplicationRecord
  has_and_belongs_to_many :products

  # 模型层数据验证
  validates :setting_type, :position, presence: true, on: :create
  validates :sort, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :setting_type, inclusion: { in: [Settings.SETTING.HOME_PRODUCT.VALUE] }
  validates :position, inclusion: { in: [0,
                                         Settings.PRODUCT_CATEGORY.SINGLE_SETMEAL,
                                         Settings.PRODUCT_CATEGORY.PERSONAL_SETMEAL,
                                         Settings.PRODUCT_CATEGORY.TEAM_SETMEAL] }
  validates :is_deleted, inclusion: { in: [true, false] }, allow_nil: true

end
