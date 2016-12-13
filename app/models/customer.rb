class Customer < ApplicationRecord
  has_many :orders, as: :buyer
  has_many :shopping_carts, as: :owner
  has_many :addresses
  # 收藏
  has_many :collections, as: :owner
end
