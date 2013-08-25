class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.integer :h2h_match_id
      t.integer :manager_id
      t.string :name
      t.integer :games_left
      t.boolean :captain
      t.string :position
      t.integer :points
      t.integer :minutes_played
      t.boolean :match_over

      t.timestamps
    end
  end
end
