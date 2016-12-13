class ModifyFiledToOrders < ActiveRecord::Migration[5.0]
  def change
    remove_columns(:orders, :product_id, :unit_price, :amount, :seller_id, :seller_type)
    rename_column(:orders, :uuid, :order_number)
    change_column(:orders, :order_number, :string, limit: 256)
    add_column(:orders, :pay_away, :integer)
    add_column(:orders, :time_start, :datetime)
    add_column(:orders, :time_expire, :datetime)
    add_column(:orders, :consignee_name, :string, limit: 32)
    add_column(:orders, :consignee_phone, :string, limit: 32)
    add_column(:orders, :consignee_address, :string, limit: 256)
  end
end
