class RenameObjectToOwnerShoppingCarts < ActiveRecord::Migration[5.0]
  def change
    rename_column(:shopping_carts, :object_id, :owner_id)
    rename_column(:shopping_carts, :object_type, :owner_type)
  end
end
