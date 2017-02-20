class AddDisplayQuantityDisplayUnitToPrices < ActiveRecord::Migration[5.0]
  def change
    add_column :prices, :display_quantity, :float
    add_column :prices, :display_unit, :string
  end
end
