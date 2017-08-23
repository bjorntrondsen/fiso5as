Fabricator(:match) do
  game_week { 1 }
  home_team { Fabricate(:team) }
  away_team { Fabricate(:team) }
  starts_at { Time.zone.now }
  ends_at { 1.day.from_now }
end
