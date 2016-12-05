class CreateCollections < ActiveRecord::Migration[5.0]
  def change
    create_table :collections do |t|
      t.integer :product_id
      t.string :owner_type
      t.integer :owner_id
      t.boolean :is_deleted
      t.string :remark, :limit => 255
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
