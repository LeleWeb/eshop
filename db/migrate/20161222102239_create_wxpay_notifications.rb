class CreateWxpayNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :wxpay_notifications do |t|
      t.integer :order_id
      t.string :appid, :limit => 32
      t.string :mch_id, :limit => 32
      t.string :device_info, :limit => 32
      t.string :nonce_str, :limit => 32
      t.string :sign, :limit => 32
      t.string :sign_type, :limit => 32
      t.string :result_code, :limit => 16
      t.string :err_code, :limit => 32
      t.string :err_code_des, :limit => 128
      t.string :openid, :limit => 128
      t.string :is_subscribe, :limit => 1
      t.string :trade_type, :limit => 16
      t.string :bank_type, :limit => 16
      t.integer :total_fee
      t.integer :settlement_total_fee
      t.string :fee_type, :limit => 8
      t.integer :cash_fee
      t.string :cash_fee_type, :limit => 16
      t.string :coupon_fee, :limit => 10
      t.string :transaction_id, :limit => 32
      t.string :out_trade_no, :limit => 32
      t.string :attach, :limit => 128
      t.string :time_end, :limit => 14

      t.timestamps
    end
  end
end
