class ShoppingCart < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :product
  belongs_to :price

  # 支持团队套餐添加购物车，使用购物车项自连接解决此问题。
  has_many :subitems, class_name: "ShoppingCart", foreign_key: "parent_id"

  belongs_to :parent, class_name: "ShoppingCart"

  # 模型层数据验证
  validates :product_id, :amount, :price_id, :total_price, :property, presence: true, on: :create
  validates :product_id, :price_id, :amount, :owner_id, numericality: { only_integer: true, greater_than: 0 }
  validates :order_id, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :total_price, numericality: { greater_than: 0 }
  validates :property, inclusion: { in: [Settings.CART_OR_ITEM.PROPERTY.CART_ITEM, Settings.CART_OR_ITEM.PROPERTY.ORDER_DETAILS_ITEM] }
  validates :is_deleted, inclusion: { in: [true, false] }
  validates :owner_type, inclusion: { in: ['Customer'] }
  validates :remark, length: { maximum: 255 }
  # 购物车的修改只支持修改: amount, total_price.
  validates :amount, :total_price, presence: true, on: :update
end
