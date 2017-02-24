class AddFieldsToShoppingCarts < ActiveRecord::Migration[5.0]
  def change
    add_column :shopping_carts, :price_id, :integer, null: false
    change_column :shopping_carts, :amount, :integer, default: 0, null: false
    add_column :shopping_carts, :total_price, :float, default: 0.0, null: false
  end
end
