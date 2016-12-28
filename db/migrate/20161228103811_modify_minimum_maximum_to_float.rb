class ModifyMinimumMaximumToFloat < ActiveRecord::Migration[5.0]
  def up
    change_column(:distribution_levels, :minimum, :float)
    change_column(:distribution_levels, :maximum, :float)
  end

  def down
    change_column(:distribution_levels, :minimum, :string)
    change_column(:distribution_levels, :maximum, :string)
  end
end
