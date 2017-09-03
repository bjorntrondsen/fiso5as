class RemoveGameWeekFromMatches < ActiveRecord::Migration[5.1]
  def change
    remove_column :matches, :game_week, :integer
    remove_column :matches, :starts_at, :datetime
    remove_column :matches, :ends_at, :datetime
  end
end
