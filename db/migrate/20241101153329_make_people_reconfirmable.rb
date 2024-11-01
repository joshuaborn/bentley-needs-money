class MakePeopleReconfirmable < ActiveRecord::Migration[7.2]
  def change
    change_table(:people) do |t|
      t.string :unconfirmed_email
    end
  end
end
