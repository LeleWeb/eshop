class CreateDistributionLevels < ActiveRecord::Migration[5.0]
  def change
    create_table :distribution_levels do |t|

      t.timestamps
    end
  end
end
