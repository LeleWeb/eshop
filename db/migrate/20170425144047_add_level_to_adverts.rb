class AddLevelToAdverts < ActiveRecord::Migration[5.0]
  def change
    add_column :adverts, :level, :integer
  end
end
