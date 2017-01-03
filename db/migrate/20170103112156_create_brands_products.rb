class CreateBrandsProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :brands_products, id: false  do |t|
      t.belongs_to :brand
      t.belongs_to :product
    end
  end
end
