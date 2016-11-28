class DeletePasswordToAccounts < ActiveRecord::Migration[5.0]
  def change
    remove_column :accounts, :password
  end
end
