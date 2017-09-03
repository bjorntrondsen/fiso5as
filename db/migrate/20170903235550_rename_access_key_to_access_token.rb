class RenameAccessKeyToAccessToken < ActiveRecord::Migration[5.1]
  def change
    rename_column :game_weeks, :access_key, :access_token
  end
end
