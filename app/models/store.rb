class Store < ApplicationRecord
  has_and_belongs_to_many :products
  has_many :orders, as: :seller
  has_many :orders, as: :buyer
  has_many :shopping_carts, as: :owner
end
