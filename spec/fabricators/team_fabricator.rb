Fabricator(:team) do
  name { 'Killer Bees' }
  fpl_id { rand(10000) }
  fiso_team_id { rand(10000) }
end

Fabricator(:eagles, from: :team) do
  name { 'Eagles' }
  fpl_id 169066
end

Fabricator(:moderators, from: :team) do
  name { 'Moderators' }
  fpl_id 213779
end
