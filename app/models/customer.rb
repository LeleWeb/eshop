class Customer < ApplicationRecord
  has_many :orders, as: :buyer
  has_many :shopping_carts, as: :owner
  has_many :addresses
  # 收藏
  has_many :collections, as: :owner
  # 分销
  has_many :distributions, as: :owner
  # 银行账号
  has_many :bank_accounts
  # 体现申请
  has_many :withdraw_details
  # 用户账户
  has_one :customer_account
end
