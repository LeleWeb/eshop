class CreateStores < ActiveRecord::Migration[5.0]
  def change
    create_table :stores do |t|
      t.integer :account_id
      t.string :name, :limit => 50
      t.string :description, :limit => 255
      t.integer :type
      t.string :address, :limit => 255
      t.string :mobile_number, :limit => 50
      t.string :remark, :limit => 255
      t.timestamps
    end
  end
end
