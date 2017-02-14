class AddPaymentTimeToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :payment_time, :datetime
  end
end
