module ApplicationHelper
  def direct_match_link(match)
    root_url + "#{match.game_week.access_token}/matches/#{match.id}"
  end
end
