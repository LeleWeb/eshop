class CreateAdverts < ActiveRecord::Migration[5.0]
  def change
    create_table :adverts do |t|

      t.timestamps
    end
  end
end
