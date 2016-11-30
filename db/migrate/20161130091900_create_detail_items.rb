class CreateDetailItems < ActiveRecord::Migration[5.0]
  def change
    create_table :detail_items do |t|
      t.string :name, :limit => 50
      t.string :remark, :limit => 255
      t.boolean :is_deleted
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
