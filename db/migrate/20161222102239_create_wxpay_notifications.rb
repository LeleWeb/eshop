class CreateWxpayNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :wxpay_notifications do |t|

      t.timestamps
    end
  end
end
