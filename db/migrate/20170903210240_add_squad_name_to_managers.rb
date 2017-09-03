class AddSquadNameToManagers < ActiveRecord::Migration[5.1]
  def change
    add_column :managers, :squad_name, :string
  end
end
