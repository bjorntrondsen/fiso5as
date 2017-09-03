namespace :matches do
  desc "Create match"
  task :create => :environment  do
    ActiveRecord::Base.transaction do
      game_week = GameWeek.find_or_create_by(gw_no: 3, season: '17/18')
      group_a = Team.order(:fiso_team_id)[0..16].shuffle
      group_b = Team.order(:fiso_team_id)[17..-1].shuffle
      raise "Groups dont match" unless group_a.length == group_b.length
      ActiveRecord::Base.transaction do
        group_a.each_with_index do |home_team, index|
          away_team = group_b[index]
          game_week.matches.create!(home_team: home_team, away_team: away_team)
        end
      end
    end
  end
end
