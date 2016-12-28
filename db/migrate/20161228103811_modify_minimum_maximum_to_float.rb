class ModifyMinimumMaximumToFloat < ActiveRecord::Migration[5.0]
  def change
    change_column(:distribution_levels, :minimum, :float)
    change_column(:distribution_levels, :maximum, :float)
  end
end
