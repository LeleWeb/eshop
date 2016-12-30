class AddIsDeletedToDistributionLevels < ActiveRecord::Migration[5.0]
  def change
    add_column :distribution_levels, :is_deleted, :boolean
  end
end
