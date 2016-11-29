class AddTypeToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :type, :integer, default: 0, null: false
  end
end
