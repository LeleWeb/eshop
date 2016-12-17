class ModifyTotalPriceFloatOrders < ActiveRecord::Migration[5.0]
  def change
    change_column(:orders, :total_price, :float)
  end
end
