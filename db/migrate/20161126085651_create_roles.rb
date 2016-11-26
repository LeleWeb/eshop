class CreateRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :roles do |t|
      t.string :name, :limit => 50
      t.string :remark, :limit => 255
      t.timestamps
    end
  end
end
