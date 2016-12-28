class CreateDistributionLevels < ActiveRecord::Migration[5.0]
  def change
    create_table :distribution_levels do |t|
      t.float :commission_ratio
      t.integer :level
      t.float :minimum
      t.float :maximum
      t.string :remark, :limit => 256

      t.timestamps
    end
  end
end
