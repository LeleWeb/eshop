class CreateCategoriesClassifications < ActiveRecord::Migration[5.0]
  def change
    create_table :categories_classifications do |t|

      t.timestamps
    end
  end
end
