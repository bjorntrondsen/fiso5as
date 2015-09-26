namespace :matches do
  desc "Create match"
  task :create => :environment  do
    ActiveRecord::Base.transaction do
      #home_team = Team.create!(fpl_id: 16137, name: "Eagles")
      #home1 = home_team.managers.create(fpl_id: 38991, fiso_name: 'From4Corners')
      #home2 = home_team.managers.create(fpl_id: 1861, fiso_name: 'Moist von Lipwig')
      #home3 = home_team.managers.create(fpl_id: 26478, fiso_name: 'Le Red')
      #home4 = home_team.managers.create(fpl_id: 120647, fiso_name: 'OatFedgoat')
      #home5 = home_team.managers.create(fpl_id: 51639, fiso_name: 'Sharagoz')
      home_team = Team.find_by(name: "Eagles")
      home1 = home_team.managers.find_by(fiso_name: 'From4Corners')
      home2 = home_team.managers.find_by(fiso_name: 'Moist von Lipwig')
      home3 = home_team.managers.find_by(fiso_name: 'Le Red')
      home4 = home_team.managers.find_by(fiso_name: 'Sharagoz')
      home5 = home_team.managers.find_by(fiso_name: 'OatFedGoat')

      away_team = Team.create!(fpl_id: 364749, name: "Vipers")
      away1 = away_team.managers.create!(fpl_id: 465, fiso_name: 'Loosecannon85')
      away2 = away_team.managers.create!(fpl_id: 3494, fiso_name: 'Neville Wears Prada')
      away3 = away_team.managers.create!(fpl_id: 14, fiso_name: 'deanfar')
      away4 = away_team.managers.create!(fpl_id: 37254, fiso_name: 'mogwai')
      away5 = away_team.managers.create!(fpl_id: 9397, fiso_name: 'Skuse Me')

      starts_at = Time.parse("2015/09/26 11:45")
      ends_at   = Time.parse("2015/09/29 04:00")
      game_week = 7

      match = Match.create!(game_week: game_week, home_team_id: home_team.id, away_team_id: away_team.id, starts_at: starts_at, ends_at: ends_at)
      match.h2h_matches.create!(home_manager_id: home1.id, away_manager_id: away1.id, match_order: 1)
      match.h2h_matches.create!(home_manager_id: home2.id, away_manager_id: away2.id, match_order: 2)
      match.h2h_matches.create!(home_manager_id: home3.id, away_manager_id: away3.id, match_order: 3)
      match.h2h_matches.create!(home_manager_id: home4.id, away_manager_id: away4.id, match_order: 4)
      match.h2h_matches.create!(home_manager_id: home5.id, away_manager_id: away5.id, match_order: 5)

      puts "Match #{match.id} created"

      match.fpl_sync
    end
  end
end
