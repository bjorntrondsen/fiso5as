namespace :matches do
  desc "Create match"
  task :create => :environment  do
    ActiveRecord::Base.transaction do
      home_team = Team.create!(fpl_id: 109081, name: "Killer Bees")
      home5 = home_team.managers.create!(fpl_id: 432374, fiso_name: 'Lovely_Camel')
      home1 = home_team.managers.create!(fpl_id: 470, fiso_name: 'Moist von Lipwig')
      home4 = home_team.managers.create!(fpl_id: 187870, fiso_name: 'Sharagoz')
      home3 = home_team.managers.create!(fpl_id: 785, fiso_name: 'From4Corners')
      home2 = home_team.managers.create!(fpl_id: 629200, fiso_name: 'McNulty')

      away_team = Team.create!(fpl_id: 274651, name: "Irritants")
      away2 = away_team.managers.create!(fpl_id: 675948, fiso_name: 'Wyld')
      away4 = away_team.managers.create!(fpl_id: 603709, fiso_name: 'Llama')
      away1 = away_team.managers.create!(fpl_id: 735104, fiso_name: 'Deanbarrono')
      away3 = away_team.managers.create!(fpl_id: 32003, fiso_name: 'travatron')
      away5 = away_team.managers.create!(fpl_id: 555192, fiso_name: 'Saturn XI')

      starts_at = Time.parse("2013/08/24 11:45")
      ends_at = Time.parse("2013/08/27 20:00")
      game_week = 2
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
