class ModifyIsDeletedToShoppingCarts < ActiveRecord::Migration[5.0]
  def change
    remove_column :shopping_carts, :is_deleted
    add_column :shopping_carts, :is_deleted, :boolean, default: false, null: false
  end
end
