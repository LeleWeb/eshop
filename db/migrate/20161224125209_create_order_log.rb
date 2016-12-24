class CreateOrderLog < ActiveRecord::Migration[5.0]
  def change
    create_table :order_logs do |t|
      t.integer :order_id
      t.integer :operator_type
      t.integer :operator_id
      t.integer :action_number
      t.datetime :operate_time

      t.timestamps
    end
  end
end
