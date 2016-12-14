class AddPayPriceToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :pay_price, :float
  end
end
