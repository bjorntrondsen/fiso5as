class RemoveMatchStatusFromPlayers < ActiveRecord::Migration[5.1]
  def change
    remove_column :players, :match_status
  end
end
