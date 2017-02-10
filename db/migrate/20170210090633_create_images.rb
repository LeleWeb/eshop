class CreateImages < ActiveRecord::Migration[5.0]
  def change
    create_table :images do |t|
      t.string :name, :limit => 255
      t.integer :imageable_id
      t.string :imageable_type, :limit => 50
      t.string :remark, :limit => 255
      t.boolean :is_deleted
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
