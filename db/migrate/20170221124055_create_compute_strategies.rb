class CreateComputeStrategies < ActiveRecord::Migration[5.0]
  def change
    create_table :compute_strategies do |t|
      t.integer :product_id
      t.integer :classify
      t.float :average_quantity
      t.integer :average_unit
      t.integer :remark
      t.boolean :is_deleted
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
