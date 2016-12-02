class Product < ApplicationRecord
  has_and_belongs_to_many :stores
  has_many :product_details
  belongs_to :category
end
