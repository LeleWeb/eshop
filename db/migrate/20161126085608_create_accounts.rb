class CreateAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :accounts do |t|
      t.string :uuid, :limit => 32
      t.string :mobile_number, :limit => 50
      t.string :email, :limit => 50
      t.string :password, :limit => 32
      t.timestamps
    end
  end
end
