class CreateCustomerAccountDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :customer_account_details do |t|

      t.timestamps
    end
  end
end
