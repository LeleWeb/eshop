class ShoppingCart < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :product
  belongs_to :price

  # 支持团队套餐添加购物车，使用购物车项自连接解决此问题。
  has_many :subitems, class_name: "ShoppingCart", foreign_key: "parent_id"

  belongs_to :parent, class_name: "ShoppingCart"
end
