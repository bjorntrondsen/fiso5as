class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.integer :game_week
      t.integer :home_team_id
      t.integer :away_team_id
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps
    end
  end
end
