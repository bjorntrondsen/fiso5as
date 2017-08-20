class AddSideToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :side, :string
  end
end
