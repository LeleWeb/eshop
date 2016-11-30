class CreateStoresProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :stores_products do |t|
      t.integer :product_id
      t.integer :store_id
      t.timestamps
    end
  end
end
