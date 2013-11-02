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
      home2 = home_team.managers.find_by(fiso_name: 'McNulty')
      home3 = home_team.managers.find_by(fiso_name: 'From4Corners')
      home4 = home_team.managers.find_by(fiso_name: 'Lovely_Camel')
      home5 = home_team.managers.find_by(fiso_name: 'Moist von Lipwig')

      away_team = Team.create!(fpl_id: 188607, name: "Rejects")
      away1 = away_team.managers.create!(fpl_id: 639, fiso_name: 'Equipe Mons')
      away2 = away_team.managers.create!(fpl_id: 74429, fiso_name: 'StrangeCargoCrew')
      away3 = away_team.managers.create!(fpl_id: 191107, fiso_name: 'Inter Mediocrity')
      away4 = away_team.managers.create!(fpl_id: 344859, fiso_name: 'James\' Gians')
      away5 = away_team.managers.create!(fpl_id: 45369, fiso_name: 'Hamburglar SV')

      starts_at = Time.parse("2013/11/02 11:45")
      ends_at = Time.parse("2013/11/03 23:59")
      game_week = 10
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
