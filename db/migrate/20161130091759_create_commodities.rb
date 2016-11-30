class CreateCommodities < ActiveRecord::Migration[5.0]
  def change
    create_table :commodities do |t|

      t.timestamps
    end
  end
end
