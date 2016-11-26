class CreateAccountsRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :accounts_roles do |t|

      t.timestamps
    end
  end
end
