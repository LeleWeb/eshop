class ModifyFiledTypeToAddresses < ActiveRecord::Migration[5.0]
  def change
    change_column(:addresses, :phone, :string)
    change_column(:addresses, :address, :string, limit: 1024)
  end
end
