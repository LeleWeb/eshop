class CreateCustomers < ActiveRecord::Migration[5.0]
  def change
    create_table :customers do |t|
      t.integer :account_id
      t.string :wechat_id, :limit => 50
      t.string :mobile_number, :limit => 50
      t.string :nick_name, :limit => 50
      t.string :heard_url, :limit => 50
      t.string :real_name, :limit => 50
      t.string :gender, :limit => 10
      t.integer :age
      t.string :address, :limit => 255
      t.boolean :is_wechat_focus
      t.integer :level
      t.integer :integral
      t.string :remark, :limit => 255
      t.timestamps
    end
  end
end
