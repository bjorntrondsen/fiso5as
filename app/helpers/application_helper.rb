module ApplicationHelper
  def friendly_match_url(match)
    "#{root_url}fiveaside/#{match.game_week.season}/#{match.game_week.gw_no}/#{match.gw_fixture_no}"
  end

  def extra_points(pts)
    if pts == 0
      ''
    elsif pts > 0
      "+#{pts}"
    elsif pts < 0
      pts
    else
      raise "Something is wrong"
    end
  end
end
