class AddCustomerIdToCustomerAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :customer_accounts, :customer_id, :integer
  end
end
