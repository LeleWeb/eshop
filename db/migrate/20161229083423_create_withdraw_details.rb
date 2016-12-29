class CreateWithdrawDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :withdraw_details do |t|

      t.timestamps
    end
  end
end
