class CreatePrices < ActiveRecord::Migration[5.0]
  def change
    create_table :prices do |t|
      t.integer :product_id
      t.float :price
      t.float :real_price
      t.integer :unit
      t.boolean :is_default
      t.string :remark

      t.timestamps
    end
  end
end
