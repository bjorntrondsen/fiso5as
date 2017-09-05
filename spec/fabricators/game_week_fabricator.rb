Fabricator(:game_week) do
  season '201718'
  gw_no 1
  deadline_at 1.week.from_now
end
