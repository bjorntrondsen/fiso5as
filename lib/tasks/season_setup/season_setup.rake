desc "Create match"
task :season_setup => :environment  do
  ActiveRecord::Base.transaction do
    Team.destroy_all
    GameWeek.destroy_all
    doc = Roo::Spreadsheet.open((Rails.root + 'lib/tasks/season_setup/2017data.xlsx').to_s)

    # Teams
    teams = []
    doc.sheet(0).each do |row|
      next if row[0] == 'TeamID'
      team = Team.create!(fiso_team_id: row[0], name: row[1], fpl_id: row[3])
      teams[row[0]] = team
    end
    # Managers
    doc.sheet(1).each do |row|
      next if row[0] == 'TeamID'
      team = teams[row[0]]
      Manager.create!(team: team, fpl_id: row[2], squad_name: row[3], fiso_name: row[4])
    end

    # Fixtures
    doc.sheet(2).each do |row|
      next if row[0] == 'GW'
      next if row[1].blank? # GW without fixtures
      game_week = GameWeek.find_or_create_by!(season: '201718', gw_no: row[0])
      home_team = teams[row[2]]
      away_team = teams[row[3]]
      Match.create!(game_week: game_week, gw_fixture_no: row[1], home_team: home_team, away_team: away_team)
    end
  end
end
