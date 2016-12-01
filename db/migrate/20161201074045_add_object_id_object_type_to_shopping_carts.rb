class AddObjectIdObjectTypeToShoppingCarts < ActiveRecord::Migration[5.0]
  def change
    add_column :shopping_carts, :object_id, :integer
    add_column :shopping_carts, :object_type, :string
  end
end
