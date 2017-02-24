class ShoppingCart < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :product
  belongs_to :price
end
