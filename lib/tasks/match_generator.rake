namespace :matches do
  desc "Create match"
  task :create => :environment  do
    ActiveRecord::Base.transaction do
      home_team = Team.find_by(name: "Killer Bees")
      home4 = home_team.managers.find_by(fiso_name: 'Lovely_Camel')
      home1 = home_team.managers.find_by(fiso_name: 'Moist von Lipwig')
      home5 = home_team.managers.find_by(fiso_name: 'Sharagoz')
      home3 = home_team.managers.find_by(fiso_name: 'From4Corners')
      home2 = home_team.managers.find_by(fiso_name: 'McNulty')

      away_team = Team.create!(fpl_id: 88389, name: "Kangals")
      away1 = away_team.managers.create!(fpl_id: 3576, fiso_name: 'bulgarche')
      away2 = away_team.managers.create!(fpl_id: 32456, fiso_name: 'Fred1266 FC')
      away3 = away_team.managers.create!(fpl_id: 9216, fiso_name: 'tadpole')
      away4 = away_team.managers.create!(fpl_id: 47858, fiso_name: 'Britinus')
      away5 = away_team.managers.create!(fpl_id: 57623, fiso_name: 'Scottoffee')

      starts_at = Time.parse("2013/08/31 11:45")
      ends_at = Time.parse("2013/09/02 20:00")
      game_week = 3
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
