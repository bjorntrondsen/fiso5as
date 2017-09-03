class CreateGameWeeks < ActiveRecord::Migration[5.1]
  def change
    create_table :game_weeks do |t|
      t.datetime :starts_at
      t.datetime :ends_at
      t.string :season
      t.integer :gw_no
      t.string :access_key

      t.timestamps
    end
    add_column :matches, :game_week_id, :integer
  end
end
