class CreateCustomerAccountDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :customer_account_details do |t|
      t.integer :customer_id
      t.datetime :trade_time
      t.float :expenses_receipts
      t.float :balance
      t.integer :category
      t.string :remark, :limit => 256

      t.timestamps
    end
  end
end
