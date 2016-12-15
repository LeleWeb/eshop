class AddLanguageToCustomers < ActiveRecord::Migration[5.0]
  def change
    add_column :customers, :language, :string, :limit => 50
  end
end
