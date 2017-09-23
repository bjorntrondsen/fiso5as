class AddMultiplierToPlayers < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :multiplier, :integer
    Player.update_all(multiplier: 1)
    Player.where(captain: true).update_all(multiplier: 2)
  end
end
