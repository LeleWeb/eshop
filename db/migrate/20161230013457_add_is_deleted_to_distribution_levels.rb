class AddIsDeletedToDistributionLevels < ActiveRecord::Migration[5.0]
  def change
    add_column :distribution_levels, :is_deleted, :boolean
    add_column :distribution_levels, :deleted_at, :datetime
  end
end
