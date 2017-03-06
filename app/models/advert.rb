class Advert < ApplicationRecord
  has_and_belongs_to_many :products
  has_many :images, as: :imageable

  # 模型层数据验证
  validates :title, :description, :status, :category, presence: true, on: :create
  validates :title, :description, :remark, length: { maximum: 256 }
  validates :status, inclusion: { in: [Settings.ADVERT.STATUS.NOT_PUT, Settings.ADVERT.STATUS.PUTTING, Settings.ADVERT.STATUS.WITHDRAWED] }
  validates :category, inclusion: { in: [Settings.ADVERT.CATEGORY.HOME_TOP] }
  validates :is_deleted, inclusion: { in: [true, false] }
end
