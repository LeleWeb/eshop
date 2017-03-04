class CreateGroupBuyings < ActiveRecord::Migration[5.0]
  def change
    create_table :group_buyings do |t|
      t.integer :product_id
      t.integer :current_number
      t.float :completion_rate
      t.float :target_amount
      t.float :current_amount
      t.datetime :begin_time
      t.datetime :end_time
      t.float :limit_min
      t.float :limit_max
      t.boolean :is_deleted
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
