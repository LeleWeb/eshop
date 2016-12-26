class CreateAdverts < ActiveRecord::Migration[5.0]
  def change
    create_table :adverts do |t|
      t.integer :store_id
      t.string :img_url, :limit => 256
      t.string :title, :limit => 256
      t.string :description, :limit => 256
      t.string :link_url, :limit => 256
      t.integer :status
      t.integer :category
      t.string :remark, :limit => 256
      t.string

      t.timestamps
    end
  end
end
