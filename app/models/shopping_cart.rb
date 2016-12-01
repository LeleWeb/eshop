class ShoppingCart < ApplicationRecord
  belongs_to :owner, polymorphic: true
end
