class AddFplIdToPlayers < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :fpl_id, :integer
  end
end
