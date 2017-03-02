class AddDeliveryTimeToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :delivery_time, :datetime
  end
end
