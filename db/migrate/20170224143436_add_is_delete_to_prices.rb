class AddIsDeleteToPrices < ActiveRecord::Migration[5.0]
  def change
    add_column :prices, :is_deleted, :boolean, default: false, null: false
    add_column :prices, :deleted_at, :datetime
  end
end
