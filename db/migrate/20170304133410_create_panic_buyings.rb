class CreatePanicBuyings < ActiveRecord::Migration[5.0]
  def change
    create_table :panic_buyings do |t|
      t.datetime :begin_time
      t.datetime :end_time
      t.boolean :is_deleted, default: false
      t.datetime :deleted_at
      t.timestamps
    end

    create_table :panic_buyings_products, id: false do |t|
      t.belongs_to :panic_buying, index: true
      t.belongs_to :product, index: true
    end
  end
end
