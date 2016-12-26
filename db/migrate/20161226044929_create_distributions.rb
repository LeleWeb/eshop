class CreateDistributions < ActiveRecord::Migration[5.0]
  def change
    create_table :distributions do |t|
      t.string :owner_type
      t.integer :owner_id
      t.string :remark, :limit => 256
      t.integer :parent_id, :null => true, :index => true
      t.integer :lft, :null => false, :index => true
      t.integer :rgt, :null => false, :index => true

      # optional fields
      t.integer :depth, :null => false, :default => 0
      t.integer :children_count, :null => false, :default => 0

      t.timestamps
    end
  end
end
