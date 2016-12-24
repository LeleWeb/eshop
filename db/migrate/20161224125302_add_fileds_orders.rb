class AddFiledsOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :shipping_type, :integer
    add_column :orders, :shipping_number, :string, :limit => 50
  end
end
