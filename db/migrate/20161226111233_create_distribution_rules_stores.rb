class CreateDistributionRulesStores < ActiveRecord::Migration[5.0]
  def change
    create_table :distribution_rules_stores do |t|
      t.belongs_to :distribution_rules
      t.belongs_to :stores
    end
  end
end
