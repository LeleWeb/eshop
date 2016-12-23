class Store < ApplicationRecord
  has_and_belongs_to_many :products
  has_many :orders, as: :buyer
  has_many :shopping_carts, as: :owner

  # 收藏
  has_many :collections, as: :owner

  def self.find_store(name)
    self.find_by(name: name)
  end
end
