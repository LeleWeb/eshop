class AddCategoryToImages < ActiveRecord::Migration[5.0]
  def change
    add_column :images, :category, :integer
  end
end
