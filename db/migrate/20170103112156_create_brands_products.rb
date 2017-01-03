class CreateBrandsProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :brands_products do |t|

      t.timestamps
    end
  end
end
