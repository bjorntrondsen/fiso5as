class AddChipInfoToMatches < ActiveRecord::Migration[5.1]
  def change
    add_column :h2h_matches, :home_chip, :string
    add_column :h2h_matches, :away_chip, :string
  end
end
