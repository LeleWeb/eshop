class Order < ApplicationRecord
  belongs_to :product
  # belongs_to :seller, polymorphic: true
  belongs_to :buyer, polymorphic: true
end
