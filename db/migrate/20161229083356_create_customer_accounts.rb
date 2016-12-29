class CreateCustomerAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :customer_accounts do |t|

      t.timestamps
    end
  end
end
