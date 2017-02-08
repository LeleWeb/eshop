class AddUnitToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :unit, :string
  end
end
