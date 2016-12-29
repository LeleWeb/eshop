class ModifyLevelToDistributionLevels < ActiveRecord::Migration[5.0]
  def up
    change_column(:distribution_levels, :level, :string)
  end

  def down
    change_column(:distribution_levels, :level, :integer)
  end
end
