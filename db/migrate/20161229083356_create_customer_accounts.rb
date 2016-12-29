class CreateCustomerAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :customer_accounts do |t|
      t.float :withdraw_sum
      t.string :remark
      t.timestamps
    end
  end
end
