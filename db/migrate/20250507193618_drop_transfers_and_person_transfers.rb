class DropTransfersAndPersonTransfers < ActiveRecord::Migration[8.0]
  def change
    drop_table :transfers, force: :cascade
    drop_table :person_transfers, force: :cascade
  end
end
