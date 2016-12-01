class CreateStoresProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products_stores do |t|
      t.belongs_to :store
      t.belongs_to :product
      t.timestamps
    end
  end
end
