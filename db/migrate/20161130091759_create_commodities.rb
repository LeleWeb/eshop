class CreateCommodities < ActiveRecord::Migration[5.0]
  def change
    create_table :commodities do |t|
      t.string :uuid, :limit => 32
      t.integer :store_id
      t.string :name, :limit => 255
      t.string :description, :limit => 255
      t.string :detail, :limit => 255
      t.integer :stock
      t.float :price
      t.float :real_price
      t.integer :status
      t.integer :type
      t.boolean :is_deleted
      t.string :remark, :limit => 255
      t.datatime :deleted_at
      t.timestamps
    end
  end
end
