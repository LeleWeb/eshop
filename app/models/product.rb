class Product < ApplicationRecord
  has_and_belongs_to_many :stores
  has_many :product_details
  belongs_to :category
  has_many :pictures, as: :imageable

  attr_accessor :details
end
