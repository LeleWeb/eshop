class CreateProductsSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :products_settings, id: false do |t|
      t.belongs_to :product, index: true
      t.belongs_to :setting, index: true
    end
  end
end
