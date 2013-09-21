namespace :matches do
  desc "Create match"
  task :create => :environment  do
    ActiveRecord::Base.transaction do
      home_team = Team.find_by(name: "Killer Bees")
      home1 = home_team.managers.find_by(fiso_name: 'McNulty')
      home2 = home_team.managers.find_by(fiso_name: 'From4Corners')
      home3 = home_team.managers.find_by(fiso_name: 'Sharagoz')
      home4 = home_team.managers.find_by(fiso_name: 'Moist von Lipwig')
      home5 = home_team.managers.find_by(fiso_name: 'Lovely_Camel')

      away_team = Team.create!(fpl_id: 8188, name: "Legomen")
      away1 = away_team.managers.create!(fpl_id: 20457, fiso_name: 'Alchemist')
      away2 = away_team.managers.create!(fpl_id: 20708, fiso_name: 'moonlightdribbler')
      away3 = away_team.managers.create!(fpl_id: 42857, fiso_name: 'CanaryYellow')
      away4 = away_team.managers.create!(fpl_id: 97262, fiso_name: 'sir_john_grimes')
      away5 = away_team.managers.create!(fpl_id: 149982, fiso_name: 'Jeffersdn')

      starts_at = Time.parse("2013/09/21 11:45")
      ends_at = Time.parse("2013/09/22 23:59")
      game_week = 5
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
