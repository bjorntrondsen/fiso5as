namespace :matches do
  desc "Create match"
  task :create => :environment  do
    ActiveRecord::Base.transaction do
      #home_team = Team.create!(fpl_id: 109081, name: "Killer Bees")
      #home1 = home_team.managers.create(fpl_id: 432374, fiso_name: 'Lovely_Camel')
      #home2 = home_team.managers.create(fpl_id: 785, fiso_name: 'From4Corners')
      #home3 = home_team.managers.create(fpl_id: 629200, fiso_name: 'McNulty')
      #home4 = home_team.managers.create(fpl_id: 187870, fiso_name: 'Sharagoz')
      #home5 = home_team.managers.create(fpl_id: 470, fiso_name: 'Moist von Lipwig')
      home_team = Team.find_by(name: "Killer Bees")
      home1 = home_team.managers.find_by(fiso_name: 'Sharagoz')
      home2 = home_team.managers.find_by(fiso_name: 'Moist von Lipwig')
      home3 = home_team.managers.find_by(fiso_name: 'From4Corners')
      home4 = home_team.managers.find_by(fiso_name: 'Lovely_Camel')
      home5 = home_team.managers.find_by(fiso_name: 'Bluenosey')

      away_team = Team.create!(fpl_id: 48870, name: "Aristocrats")
      away1 = away_team.managers.create!(fpl_id: 2122, fiso_name: 'spiderm4tt')
      away2 = away_team.managers.create!(fpl_id: 60786, fiso_name: 'MorrisonDullforce')
      away3 = away_team.managers.create!(fpl_id: 45224, fiso_name: 'TheDazzler')
      away4 = away_team.managers.create!(fpl_id: 67440, fiso_name: 'theplayer')
      away5 = away_team.managers.create!(fpl_id: 76, fiso_name: 'pascalevans')

      starts_at = Time.parse("2014/03/22 11:45")
      ends_at = Time.parse("2014/03/27 04:00")
      game_week = 31
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
