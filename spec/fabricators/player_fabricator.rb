Fabricator(:player) do
  fpl_id { Fabricate.sequence(:player_fpl_id) { |i| i } }
  name { (0...6).map{ ('a'..'z').to_a[rand(26)] }.join }
  bench false
  matches_over true
  minutes_played 90
  position 'FWD'
  side 'home'
  captain false
  vice_captain false
  points 2
  multiplier 1
end
