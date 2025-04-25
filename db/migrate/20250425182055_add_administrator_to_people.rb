class AddAdministratorToPeople < ActiveRecord::Migration[8.0]
  def change
    add_column :people, :administrator, :boolean
  end
end
