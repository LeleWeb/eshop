class CreateAddresses < ActiveRecord::Migration[5.0]
  def change
    create_table :addresses do |t|
      t.integer :customer_id
      t.string  :mobile_number,:limit=>50
      t.string  :detailed_address, :limit=>1024
      t.boolean :is_default
      t.string :remark, :limit => 255
      t.timestamps
    end
  end
end
