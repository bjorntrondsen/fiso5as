Fabricator(:h2h_match) do
  match { Fabricate(:match) }
  match_order 1
  home_manager { Fabricate(:manager) }
  away_manager { Fabricate(:manager) }
  before_validation do |h2h, transients|
    %w( home away ).each do |side|
      h2h.players << Fabricate(:player, side: side, position: 'GK')
      3.times { h2h.players << Fabricate(:player, side: side, position: 'DEF') }
      4.times { h2h.players << Fabricate(:player, side: side, position: 'MID') }
      3.times { h2h.players << Fabricate(:player, side: side, position: 'FWD') }
      h2h.players << Fabricate(:player, side: side, position: 'GK', bench: true)
      h2h.players << Fabricate(:player, side: side, position: 'DEF', bench: true)
      h2h.players << Fabricate(:player, side: side, position: 'DEF', bench: true)
      h2h.players << Fabricate(:player, side: side, position: 'MID', bench: true)
    end
  end
end
