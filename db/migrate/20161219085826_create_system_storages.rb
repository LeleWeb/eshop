class CreateSystemStorages < ActiveRecord::Migration[5.0]
  def change
    create_table :system_storages do |t|
      t.string :category, :limit => 50
      t.string :content, :limit => 256
      t.boolean :is_default
      t.string :remark, :limit => 256
      t.timestamps
    end
  end
end
