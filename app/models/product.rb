class Product < ApplicationRecord
  has_and_belongs_to_many :stores
  has_many :product_details
  has_and_belongs_to_many :categories

  # 商品图片
  has_many :pictures, as: :imageable
  has_many :images, as: :imageable

  # 收藏
  has_many :collections, as: :object

  has_and_belongs_to_many :orders

  attr_accessor :details

  # 广告
  has_and_belongs_to_many :adverts

  # 使用自连接将若干商品当做一个虚拟商品销售
  has_many :items, class_name: "Product",
           foreign_key: "group_id"

  belongs_to :group, class_name: "Product"

  # 价格
  has_many :prices

  # 计算策略
  has_many :compute_strategies

  # 团购
  has_one :group_buying

  # 限时抢购
  has_and_belongs_to_many :panic_buyings
end
