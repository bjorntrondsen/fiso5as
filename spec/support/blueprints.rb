require 'machinist/active_record'

Match.blueprint do
  game_week { 1 }
  home_team { Team.make! }
  away_team { Team.make! }
  starts_at { Time.zone.now }
  ends_at { 1.day.from_now }
end

Player.blueprint do
  name { 'VanPersie' }
  bench { false }
  match_over { true }
  minutes_played { 90 }
  position { 'FWD' }
  side { 'home' }
end

Team.blueprint do
  name { 'Killer Bees' }
  fpl_id { 109081 }
end
