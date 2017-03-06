class Address < ApplicationRecord
  # 模型层数据验证
  validates :customer_id, :is_default, :phone, :address, :name, presence: true, on: :create
  validates :is_default, inclusion: { in: [true, false] }
  validates :phone, format: { with: /\d{11}/, message: "手机号码格式错误" }
end
