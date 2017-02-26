class ChangeDisplayUnitToPrices < ActiveRecord::Migration[5.0]
  def change
    change_column :prices, :display_unit, :integer
  end
end
