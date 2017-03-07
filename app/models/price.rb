class Price < ApplicationRecord
  # 模型层数据验证
  validates :product_id, :price, :real_price, :unit, :display_quantity, :display_unit, presence: true, on: :create
  validates :product_id, numericality: { only_integer: true, greater_than: 0 }
  validates :price, :real_price, :display_quantity, numericality: { greater_than: 0 }
  validates :unit, :display_unit, inclusion: { in: [Settings.PRICE.JIN,
                                                    Settings.PRICE.GE,
                                                    Settings.PRICE.FEN,
                                                    Settings.PRICE.HE,
                                                    Settings.PRICE.XIANG] }
  validates :is_default, inclusion: { in: [true, false] }
  validates :remark, length: { maximum: 255 }

end
