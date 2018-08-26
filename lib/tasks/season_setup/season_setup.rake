desc "Create match"
task :season_setup => :environment  do
  ActiveRecord::Base.transaction do
    season = '201819'
    Team.where(season: season).destroy_all
    GameWeek.where(season: season).destroy_all

    # Note: 2017 and 2018 data have slight differences
    doc = Roo::Spreadsheet.open((Rails.root + 'lib/tasks/season_setup/2018data.xlsx').to_s)

    # Teams
    teams = []
    doc.sheet(0).each do |row|
      next if row[0] == 'TeamID'
      team = Team.create!(fiso_team_id: row[0], fpl_id: row[1], name: row[2], season: season)
      teams[row[0]] = team
    end
    # Managers
    doc.sheet(1).each do |row|
      next if row[0] == 'TeamID'
      team = teams[row[0]]
      Manager.create!(team: team, fpl_id: row[1], fiso_name: row[2])
    end

    # Fixtures
    doc.sheet(2).each do |row|
      next if row[0] == 'GW'
      next if row[2].blank? # GW without fixtures
      game_week = GameWeek.find_or_create_by!(season: season, gw_no: row[0])
      home_team = teams[row[2]]
      away_team = teams[row[3]]
      Match.create!(game_week: game_week, gw_fixture_no: row[1], home_team: home_team, away_team: away_team)
    end
  end
end
