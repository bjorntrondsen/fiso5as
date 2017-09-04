module ApplicationHelper
  def friendly_match_url(match)
    "#{root_url}#{match.game_week.season}/#{match.game_week.gw_no}/#{match.gw_fixture_no}"
  end
end
