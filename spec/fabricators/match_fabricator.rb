Fabricator(:match) do
  game_week { Fabricate(:game_week) }
  home_team { Fabricate(:team) }
  away_team { Fabricate(:team) }
  gw_fixture_no 1
end
