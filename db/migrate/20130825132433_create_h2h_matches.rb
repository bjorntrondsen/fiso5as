class CreateH2hMatches < ActiveRecord::Migration
  def change
    create_table :h2h_matches do |t|
      t.integer :match_id
      t.integer :match_order
      t.integer :home_manager_id
      t.integer :away_manager_id
      t.integer :home_score
      t.integer :away_score
      t.text :info

      t.timestamps
    end
  end
end
