class ModifyIsDeletedToProduction < ActiveRecord::Migration[5.0]
  def change
    change_column(:products, :is_deleted, :boolean, default: false)
  end
end
