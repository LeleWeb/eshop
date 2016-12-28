class Product < ApplicationRecord
  has_and_belongs_to_many :stores
  has_many :product_details
  has_and_belongs_to_many :categories

  # 商品图片
  has_many :pictures, as: :imageable

  # 收藏
  has_many :collections, as: :object

  has_and_belongs_to_many :orders

  attr_accessor :details

  # 广告
  has_and_belongs_to_many :adverts
end
