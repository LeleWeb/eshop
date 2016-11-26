class CreateAccountsRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :accounts_roles do |t|
      t.integer :account_id
      t.integer :role_id
      t.timestamps
    end
  end
end
