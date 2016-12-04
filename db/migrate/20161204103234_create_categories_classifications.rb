class CreateCategoriesClassifications < ActiveRecord::Migration[5.0]
  def change
    create_table :categories_classifications, id: false do |t|
      t.belongs_to :Category
      t.belongs_to :Classification
    end
  end
end
