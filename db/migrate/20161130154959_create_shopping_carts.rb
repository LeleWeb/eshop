class CreateShoppingCarts < ActiveRecord::Migration[5.0]
  def change
    create_table :shopping_carts do |t|
      t.integer :product_id
      t.integer :amount
      t.string :remark, :limit => 255
      t.boolean :is_deleted
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
