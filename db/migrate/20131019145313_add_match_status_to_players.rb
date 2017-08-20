class AddMatchStatusToPlayers < ActiveRecord::Migration[4.2]
  def change
    add_column :players, :match_status, :string, default: 'over'
  end
end
