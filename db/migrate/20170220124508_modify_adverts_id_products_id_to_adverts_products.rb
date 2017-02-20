class ModifyAdvertsIdProductsIdToAdvertsProducts < ActiveRecord::Migration[5.0]
  def change
    rename_column(:adverts_products, :adverts_id, :advert_id)
    rename_column(:adverts_products, :products_id, :product_id)
  end
end
