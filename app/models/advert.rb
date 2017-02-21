class Advert < ApplicationRecord
  has_and_belongs_to_many :products
  has_many :images, as: :imageable
end
