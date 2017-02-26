class AddOrderIdToShoppingCarts < ActiveRecord::Migration[5.0]
  def change
    add_column :shopping_carts, :order_id, :integer
  end
end
