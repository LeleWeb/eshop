class ModifyFiledToAddresses < ActiveRecord::Migration[5.0]
  def change
    rename_column(:addresses, :mobile_number, :phone)
    rename_column(:addresses, :detailed_address, :address)
    add_column(:addresses, :name, :string)
  end
end
