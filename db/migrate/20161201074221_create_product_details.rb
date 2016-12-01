class CreateProductDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :product_details do |t|
      t.integer :product_id
      t.integer :detail_item_id
      t.string :content, :limit => 50
      t.boolean :is_deleted
      t.string :remark, :limit => 255
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
