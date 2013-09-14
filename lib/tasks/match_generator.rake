namespace :matches do
  desc "Create match"
  task :create => :environment  do
    ActiveRecord::Base.transaction do
      home_team = Team.find_by(name: "Killer Bees")
      home1 = home_team.managers.find_by(fiso_name: 'Moist von Lipwig')
      home2 = home_team.managers.find_by(fiso_name: 'From4Corners')
      home3 = home_team.managers.find_by(fiso_name: 'McNulty')
      home4 = home_team.managers.find_by(fiso_name: 'Lovely_Camel')
      home5 = home_team.managers.find_by(fiso_name: 'Sharagoz')

      away_team = Team.create!(fpl_id: 88389, name: "The Zombies")
      away1 = away_team.managers.create!(fpl_id: 15999, fiso_name: 'Jazzyb69')
      away2 = away_team.managers.create!(fpl_id: 180, fiso_name: 'Bcfc1903')
      away3 = away_team.managers.create!(fpl_id: 823, fiso_name: 'Knulpuk')
      away4 = away_team.managers.create!(fpl_id: 1045, fiso_name: 'Dr Bunker')
      away5 = away_team.managers.create!(fpl_id: 274, fiso_name: 'Phantomscythe')

      starts_at = Time.parse("2013/09/14 11:45")
      ends_at = Time.parse("2013/09/16 23:59")
      game_week = 4
      match = Match.create!(game_week: game_week, home_team_id: home_team.id, away_team_id: away_team.id, starts_at: starts_at, ends_at: ends_at)
      match.h2h_matches.create!(home_manager_id: home1.id, away_manager_id: away1.id, match_order: 1)
      match.h2h_matches.create!(home_manager_id: home2.id, away_manager_id: away2.id, match_order: 2)
      match.h2h_matches.create!(home_manager_id: home3.id, away_manager_id: away3.id, match_order: 3)
      match.h2h_matches.create!(home_manager_id: home4.id, away_manager_id: away4.id, match_order: 4)
      match.h2h_matches.create!(home_manager_id: home5.id, away_manager_id: away5.id, match_order: 5)

      match.fpl_sync
    end
  end
end
