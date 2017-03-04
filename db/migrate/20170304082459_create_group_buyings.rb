class CreateGroupBuyings < ActiveRecord::Migration[5.0]
  def change
    create_table :group_buyings do |t|

      t.timestamps
    end
  end
end
