class CreateBrands < ActiveRecord::Migration[5.0]
  def change
    create_table :brands do |t|
      t.string :name
      t.integer :category
      t.integer :status
      t.string :img_url
      t.boolean :is_recommend
      t.string :remark
      t.boolean :is_deleted
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
