class ProductDetail < ApplicationRecord
  belongs_to :detail_item
  belongs_to :product
end
