class AddTypeToTransfers < ActiveRecord::Migration[7.2]
  def change
    add_column :transfers, :type, :string
  end
end
