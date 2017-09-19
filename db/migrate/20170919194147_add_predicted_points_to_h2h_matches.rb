class AddPredictedPointsToH2hMatches < ActiveRecord::Migration[5.1]
  def change
    add_column :h2h_matches, :extra_points_home, :integer, default: 0
    add_column :h2h_matches, :extra_points_away, :integer, default: 0
  end
end
