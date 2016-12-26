class CreateDistributionRules < ActiveRecord::Migration[5.0]
  def change
    create_table :distribution_rules do |t|

      t.timestamps
    end
  end
end
