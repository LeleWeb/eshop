class CreateStoresProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :stores_products do |t|
      t.belongs_to :store
      t.belongs_to :product
      t.timestamps
    end
  end
end
