class StoresProduct < ApplicationRecord
  has_and_belongs_to_many :stores
  has_many :pictures, as: :imageable
end
