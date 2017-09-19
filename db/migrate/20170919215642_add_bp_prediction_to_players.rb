class AddBpPredictionToPlayers < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :bp_prediction, :integer
    Player.update_all bp_prediction: 0
  end
end
