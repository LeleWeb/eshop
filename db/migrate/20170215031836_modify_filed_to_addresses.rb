class ModifyFiledToAddresses < ActiveRecord::Migration[5.0]
  def change
    rename_column(:addresses, :mobile_number, :phone)
    rename_column(:addresses, :detailed_address, :address)
    add_column(:addresses, :name, :string)
    add_column(:addresses, :is_default, :boolean, default: true)
  end
end
