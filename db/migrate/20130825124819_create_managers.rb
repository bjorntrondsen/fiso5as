class CreateManagers < ActiveRecord::Migration
  def change
    create_table :managers do |t|
      t.integer :fpl_id, :team_id
      t.string :fpl_name, :fiso_name

      t.timestamps
    end
  end
end
