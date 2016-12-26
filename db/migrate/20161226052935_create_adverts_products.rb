class CreateAdvertsProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :adverts_products do |t|
      t.belongs_to :adverts
      t.belongs_to :products
    end
  end
end
