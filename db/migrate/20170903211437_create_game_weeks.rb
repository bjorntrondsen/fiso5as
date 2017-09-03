class CreateGameWeeks < ActiveRecord::Migration[5.1]
  def change
    create_table :game_weeks do |t|
      t.datetime :deadline_at
      t.string :season
      t.integer :gw_no
      t.string :access_key
      t.boolean :finished, default: false

      t.timestamps
    end
    add_column :matches, :game_week_id, :integer
  end
end
