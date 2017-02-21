class AddIsDeletedDeletedAtToAdverts < ActiveRecord::Migration[5.0]
  def change
    add_column :adverts, :is_deleted, :boolean, default: false
    add_column :adverts, :deleted_at, :datetime
  end
end
