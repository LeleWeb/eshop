class Category < ApplicationRecord
  acts_as_nested_set
  # has_many :products
  has_many :pictures, as: :imageable
  has_and_belongs_to_many :products
end
