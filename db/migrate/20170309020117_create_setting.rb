class CreateSetting < ActiveRecord::Migration[5.0]
  def change
    create_table :settings do |t|
      t.integer :setting_type, default: 0
      t.integer :position, default: 0
      t.integer :sort, default: 0
      t.boolean :is_deleted, default: false
      t.datetime :deleted_at
    end
  end
end
