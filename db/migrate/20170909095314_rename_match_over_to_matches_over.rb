class RenameMatchOverToMatchesOver < ActiveRecord::Migration[5.1]
  def change
    rename_column :players, :match_over, :matches_over
  end
end
