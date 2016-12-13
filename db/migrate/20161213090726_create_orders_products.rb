class CreateOrdersProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :orders_products do |t|
      t.belongs_to :order
      t.belongs_to :product
    end
  end
end
