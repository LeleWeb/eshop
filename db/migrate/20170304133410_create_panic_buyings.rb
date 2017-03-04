class CreatePanicBuyings < ActiveRecord::Migration[5.0]
  def change
    create_table :panic_buyings do |t|

      t.timestamps
    end
  end
end
