class CreateWithdrawDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :withdraw_details do |t|
      t.integer :customer_id
      t.integer :store_id
      t.float :sum
      t.datetime :operate_time
      t.integer :status
      t.string :remark
      t.timestamps
    end
  end
end
