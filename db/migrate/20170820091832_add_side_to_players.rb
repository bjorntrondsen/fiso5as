class AddSideToPlayers < ActiveRecord::Migration[4.2]
  def change
    add_column :players, :side, :string
    add_index :players, [:side, :h2h_match_id]
  end
end
