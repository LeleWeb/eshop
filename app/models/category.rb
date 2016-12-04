class Category < ApplicationRecord
  acts_as_nested_set
  has_many :products
  has_many :pictures, as: :imageable
end
