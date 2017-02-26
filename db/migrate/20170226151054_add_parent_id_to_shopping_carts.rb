class AddParentIdToShoppingCarts < ActiveRecord::Migration[5.0]
  def change
    add_column :shopping_carts, :parent_id, :integer
  end
end
