namespace :matches do
  desc "Create match"
  task :create => :environment  do
    ActiveRecord::Base.transaction do
      home_team = Team.find_by(name: "Killer Bees")
      home1 = home_team.managers.find_by(fiso_name: 'From4Corners')
      home2 = home_team.managers.find_by(fiso_name: 'McNulty')
      home3 = home_team.managers.find_by(fiso_name: 'Lovely_Camel')
      home4 = home_team.managers.find_by(fiso_name: 'Moist von Lipwig')
      home5 = home_team.managers.find_by(fiso_name: 'Sharagoz')

      away_team = Team.create!(fpl_id: 79596, name: "The Moderators")
      away1 = away_team.managers.create!(fpl_id: 1151978, fiso_name: 'AKNel1')
      away2 = away_team.managers.create!(fpl_id: 268397, fiso_name: 'Jester')
      away3 = away_team.managers.create!(fpl_id: 322338, fiso_name: 'Mystery')
      away4 = away_team.managers.create!(fpl_id: 651785, fiso_name: 'Barry')
      away5 = away_team.managers.create!(fpl_id: 4837, fiso_name: 'Vid')

      starts_at = Time.parse("2013/09/28 11:45")
      ends_at = Time.parse("2013/09/30 23:59")
      game_week = 6
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
