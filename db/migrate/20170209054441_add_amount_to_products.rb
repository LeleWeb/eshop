class AddAmountToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :amount, :integer
  end
end
