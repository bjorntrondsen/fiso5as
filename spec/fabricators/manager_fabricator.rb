Fabricator(:manager) do
  team { Fabricate(:team) }
  fpl_id { rand(10000) }
end
