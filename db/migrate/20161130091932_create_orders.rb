class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.string :uuid, :limit => 32
      t.integer :product_id
      t.float :unit_price
      t.integer :amount
      t.integer :status
      t.float :total_price
      t.integer :buyer_id
      t.string :buyer_type, :limit => 50
      t.integer :seller_id
      t.string :seller_type, :limit => 50
      t.integer :estimate
      t.string :remark, :limit => 255
      t.boolean :is_deleted
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
