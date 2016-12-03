class RenameTypeToPropertyTostores < ActiveRecord::Migration[5.0]
  def change
    rename_column(:stores, :type, :property)
  end
end
