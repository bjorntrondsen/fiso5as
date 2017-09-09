class AddLastSyncTookToGameWeeks < ActiveRecord::Migration[5.1]
  def change
    add_column :game_weeks, :last_sync_took, :decimal, precision: 5, scale: 1
  end
end
