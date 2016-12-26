class CreateDistributionRules < ActiveRecord::Migration[5.0]
  def change
    create_table :distribution_rules do |t|
      t.integer :store_id
      t.string :name, :limit => 256
      t.integer :category
      t.string :value, :limit => 256
      t.string :remark, :limit => 256

      t.timestamps
    end
  end
end
