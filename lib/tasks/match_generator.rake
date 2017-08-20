namespace :matches do
  desc "Create match"
  task :create => :environment  do
    ActiveRecord::Base.transaction do
      game_week = 2
      starts_at = Time.zone.now.beginning_of_week.advance(days: 5, hours: 11, minutes: 45)
      ends_at   = Time.zone.now.beginning_of_week.advance(days: 7, hours: 4)
      group_a = [
        209137,
        112989,
        434145,
        351221,
        581248,
        198390,
        499903,
        137931,
        54271,
        317753,
        3052
      ]
      group_b = [
        173853,
        4362,
        57214,
        45951,
        9229,
        147089,
        57126,
        386578,
        384311,
        345980,
        27056
      ]
      ActiveRecord::Base.transaction do
        group_a.each_with_index do |home_team_id, index|
          away_team_id = group_b[index]
          match = Match.new(home_team_id: home_team_id, away_team_id: away_team_id, game_week: game_week, starts_at: starts_at, ends_at: ends_at)
          match.set_up_match!
        end
      end
    end
  end
end
