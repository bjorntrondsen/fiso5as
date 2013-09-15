require 'machinist/active_record'

Player.blueprint do
  name { 'VanPersie' }
  bench { false }
end
