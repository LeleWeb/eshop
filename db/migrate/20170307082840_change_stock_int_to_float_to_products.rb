class ChangeStockIntToFloatToProducts < ActiveRecord::Migration[5.0]
  def change
    change_column(:products, :stock, :float)
  end
end
