class CreateBankAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :bank_accounts do |t|
      t.integer :customer_id
      t.string :name
      t.string :card_number
      t.string :bank
      t.boolean :is_default
      t.timestamps
    end
  end
end
