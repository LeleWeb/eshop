class CreateDetailItems < ActiveRecord::Migration[5.0]
  def change
    create_table :detail_items do |t|

      t.timestamps
    end
  end
end
