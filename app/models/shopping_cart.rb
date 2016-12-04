class ShoppingCart < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :product
end
