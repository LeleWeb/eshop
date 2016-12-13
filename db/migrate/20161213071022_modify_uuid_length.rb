class ModifyUuidLength < ActiveRecord::Migration[5.0]
  def change
    change_column(:accounts, :uuid, :string, limit: 255)
    change_column(:orders, :uuid, :string, limit: 255)
    change_column(:products, :uuid, :string, limit: 255)
  end
end
