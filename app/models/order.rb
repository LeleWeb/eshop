class Order < ApplicationRecord
  has_and_belongs_to_many :products
  # belongs_to :seller, polymorphic: true
  belongs_to :buyer, polymorphic: true
  has_many :order_details

  # 订单操作日志
  has_many :order_logs
  # 订单项
  has_many :shopping_carts

  # 模型层数据验证
  validates :order_number, :total_price, :buyer_id, :buyer_type, :pay_away, :consignee_name, :consignee_phone,
            :consignee_address, :delivery_time, presence: true, on: :create
  validates :order_number, length: { maximum: 255 }
  validates :status, inclusion: { in: [Settings.ORDER.STATUS.CANCEL,
                                       Settings.ORDER.STATUS.PREPAY,
                                       Settings.ORDER.STATUS.PAID,
                                       Settings.ORDER.STATUS.DELIVERED,
                                       Settings.ORDER.STATUS.COMPLETED,
                                       Settings.ORDER.STATUS.REFUNDING,
                                       Settings.ORDER.STATUS.REFUND] }
  validates :total_price, numericality: { greater_than: 0 }
  validates :pay_price, numericality: { greater_than: 0 }, allow_nil: true
  validates :buyer_id, numericality: { only_integer: true, greater_than: 0 }
  validates :buyer_type, inclusion: { in: ['Customer'] }
  validates :remark, :consignee_address, length: { maximum: 255 }
  validates :consignee_name, :consignee_phone, length: { maximum: 32 }
  validates :consignee_phone, format: { with: /\d{11}/, message: "手机号码格式错误" }
  validates :is_deleted, inclusion: { in: [true, false] }, allow_nil: true
  validates :pay_away, inclusion: { in: [Settings.ORDER.PAY_AWAY.WXPAY.VALUE,
                                         Settings.ORDER.PAY_AWAY.COD.VALUE] }
  validates :payment_time, :delivery_time, format: { with: /\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}/, message: "时间格式错误" }
end
