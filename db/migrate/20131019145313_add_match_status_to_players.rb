class AddMatchStatusToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :match_status, :string, default: 'over'
  end
end
