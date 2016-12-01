class Customer < ApplicationRecord
  has_many :orders, as: :buyer
  has_many :shopping_carts, as: :owner
end
