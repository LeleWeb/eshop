class AddCategroyToPictures < ActiveRecord::Migration[5.0]
  def change
    add_column :pictures, :category, :integer
  end
end
