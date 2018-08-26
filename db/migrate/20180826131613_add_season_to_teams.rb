class AddSeasonToTeams < ActiveRecord::Migration[5.1]
  class Team < ApplicationRecord; end

  def change
    add_column :teams, :season, :string
    Team.where(season: nil).update_all(season: '201718')
  end
end
