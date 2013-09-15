require 'machinist/active_record'

Player.blueprint do
  name { 'VanPersie' }
  bench { false }
  match_over { true }
  minutes_played { 90 }
  position { 'FWD' }
end
