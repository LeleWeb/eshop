class CreateGroupBuyings < ActiveRecord::Migration[5.0]
  def change
    create_table :group_buyings do |t|
      t.integer :product_id
      t.integer :current_number, default: 0
      t.float :completion_rate, default: 0
      t.float :target_amount, default: 0
      t.float :current_amount, default: 0
      t.datetime :begin_time
      t.datetime :end_time
      t.float :limit_min, default: 0
      t.float :limit_max, default: 0
      t.boolean :is_deleted, default: false
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
