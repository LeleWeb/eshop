class ModifyTotalPriceIntOrders < ActiveRecord::Migration[5.0]
  def change
    change_column(:orders, :total_price, :integer)
  end
end
