namespace :matches do
  desc "Create match"
  task :create => :environment  do
    ActiveRecord::Base.transaction do
      #home_team = Team.create!(fpl_id: 439845, name: "Eagles")
      #home1 = home_team.managers.create(fpl_id: 112, fiso_name: 'Moist von Lipwig')
      #home2 = home_team.managers.create(fpl_id: 43124, fiso_name: 'Wahl84')
      #home3 = home_team.managers.create(fpl_id: 271474, fiso_name: 'Sharagoz')
      #home4 = home_team.managers.create(fpl_id: 16153, fiso_name: 'From4Corners')
      #home5 = home_team.managers.create(fpl_id: 1436344, fiso_name: 'Le Red')
      home_team = Team.find_by(name: "Eagles")
      home1 = home_team.managers.find_by(fiso_name: 'Moist von Lipwig')
      home2 = home_team.managers.find_by(fiso_name: 'Wahl84')
      home3 = home_team.managers.find_by(fiso_name: 'Le Red')
      home4 = home_team.managers.find_by(fiso_name: 'Sharagoz')
      home5 = home_team.managers.find_by(fiso_name: 'From4Corners')

      away_team = Team.create!(fpl_id: 121538, name: "Rogues")
      away1 = away_team.managers.create!(fpl_id: 200235, fiso_name: 'ell-ess-dee')
      away2 = away_team.managers.create!(fpl_id: 28312, fiso_name: 'Dronning Maud Land')
      away3 = away_team.managers.create!(fpl_id: 1027639, fiso_name: 'llama')
      away4 = away_team.managers.create!(fpl_id: 200909, fiso_name: 'snout')
      away5 = away_team.managers.create!(fpl_id: 9013, fiso_name: 'doogal')

      starts_at = Time.parse("2014/09/13 11:45")
      ends_at = Time.parse("2014/09/16 04:00")
      game_week = 4

      match = Match.create!(game_week: game_week, home_team_id: home_team.id, away_team_id: away_team.id, starts_at: starts_at, ends_at: ends_at)
      match.h2h_matches.create!(home_manager_id: home1.id, away_manager_id: away1.id, match_order: 1)
      match.h2h_matches.create!(home_manager_id: home2.id, away_manager_id: away2.id, match_order: 2)
      match.h2h_matches.create!(home_manager_id: home3.id, away_manager_id: away3.id, match_order: 3)
      match.h2h_matches.create!(home_manager_id: home4.id, away_manager_id: away4.id, match_order: 4)
      match.h2h_matches.create!(home_manager_id: home5.id, away_manager_id: away5.id, match_order: 5)

      #match.fpl_sync
    end
  end
end
