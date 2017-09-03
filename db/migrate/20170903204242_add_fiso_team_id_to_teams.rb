class AddFisoTeamIdToTeams < ActiveRecord::Migration[5.1]
  def change
    add_column :teams, :fiso_team_id, :integer
  end
end
