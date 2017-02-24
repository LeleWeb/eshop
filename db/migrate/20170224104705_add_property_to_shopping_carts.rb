class AddPropertyToShoppingCarts < ActiveRecord::Migration[5.0]
  def change
    add_column :shopping_carts, :property, :integer, default: 0, null: false
  end
end
