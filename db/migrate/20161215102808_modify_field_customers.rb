class ModifyFieldCustomers < ActiveRecord::Migration[5.0]
  def change
    remove_column :customers, :wechat_id
    remove_column :customers, :nick_name
    remove_column :customers, :heard_url
    remove_column :customers, :is_wechat_focus

    add_column :customers, :access_token, :string, :limit=>256
    add_column :customers, :expires_in, :integer
    add_column :customers, :refresh_token, :string, :limit=>256
    add_column :customers, :openid, :string, :limit=>256
    add_column :customers, :scope, :string, :limit=>50
    add_column :customers, :unionid, :string, :limit=>256
    add_column :customers, :nickname, :string, :limit=>256
    add_column :customers, :sex, :integer
    add_column :customers, :province, :string, :limit=>50
    add_column :customers, :city, :string, :limit=>50
    add_column :customers, :country, :string, :limit=>50
    add_column :customers, :headimgurl, :string, :limit=>256
    add_column :customers, :privilege, :string, :limit=>256
  end
end
