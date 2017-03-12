class AddFieldToShoppingCarts < ActiveRecord::Migration[5.0]
  def change
    add_column :shopping_carts, :product_img, :string, default: ""
    add_column :shopping_carts, :product_name, :string, default: ""
    add_column :shopping_carts, :product_desc, :string, default: ""
    add_column :shopping_carts, :product_price, :float, default: 0
    add_column :shopping_carts, :product_unit, :integer, default: nil
  end
end
