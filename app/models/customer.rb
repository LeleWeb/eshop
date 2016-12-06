class Customer < ApplicationRecord
  has_many :orders, as: :buyer
  has_many :orders, as: :seller
  has_many :shopping_carts, as: :owner

  # 收藏
  has_many :collections, as: :owner
end
