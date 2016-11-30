class CreateStoresCommodities < ActiveRecord::Migration[5.0]
  def change
    create_table :stores_commodities do |t|

      t.timestamps
    end
  end
end
