class Order < ApplicationRecord
  has_and_belongs_to_many :products
  # belongs_to :seller, polymorphic: true
  belongs_to :buyer, polymorphic: true
  has_many :order_details

  # 订单操作日志
  has_many :order_logs
end
