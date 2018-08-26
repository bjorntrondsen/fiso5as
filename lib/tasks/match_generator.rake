namespace :matches do
  desc "Create match"
  task :create => :environment  do
    ActiveRecord::Base.transaction do
      game_week = GameWeek.find_or_create_by(gw_no: 3, season: '201718')
      group_a = Team.order(:fiso_team_id)[0..16].shuffle
      group_b = Team.order(:fiso_team_id)[17..-1].shuffle
      raise "Groups dont match" unless group_a.length == group_b.length
      ActiveRecord::Base.transaction do
        group_a.each_with_index do |home_team, index|
          away_team = group_b[index]
          match = game_week.matches.create!(home_team: home_team, away_team: away_team, gw_fixture_no: index + 1)
          match.set_up_match!
        end
      end
    end
  end

  desc "Create test match"
  task :test => :environment  do
    ActiveRecord::Base.transaction do
      home_team = Team.find_or_create_by!(fpl_id: 191334, fiso_team_id: 1, name: 'FISO 5AS The Eagles')
      away_team = Team.find_or_create_by!(fpl_id: 108290, fiso_team_id: 2, name: 'FISO 5AS Assassins')
      game_week = GameWeek.find_or_create_by(gw_no: 3, season: '201819')
      match = game_week.matches.create!(home_team: home_team, away_team: away_team, gw_fixture_no: 1)
      match.set_up_match!
    end
  end

end
