class ModifyOperatorTypeToString < ActiveRecord::Migration[5.0]
  def up
    change_column(:order_logs, :operator_type, :string)
  end

  def down
    change_column(:order_logs, :operator_type, :integer)
  end
end
