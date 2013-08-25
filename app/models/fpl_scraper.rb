class FplScraper
  def initialize(h2h_match)
    @h2h_match = h2h_match
    @match = h2h_match.match
  end

  def scrape
    fetch_data(@h2h_match.home_manager, :home)
    fetch_data(@h2h_match.away_manager, :away)
  end

  private

  def fetch_data(manager, side)
    gw_url = "#{manager.fpl_url}/#{@match.game_week}/"
    @doc = Nokogiri::HTML(open(gw_url))
    score = @doc.at_css('.ismSB .ismSBPrimary > div').content.strip.scan(/\A\d{1,}/).first.to_i
    @h2h_match.home_score = score if(side == :home)
    @h2h_match.away_score = score if(side == :away)
    @doc.css('.ismPitch .ismPitchElement').each do |player_element|
      json_str = player_element['class'].sub('ismPitchElement','')
      player_json = JSON.parse(json_str)
      attributes = player_data(player_element, player_json)
      attributes[:manager_id] = manager.id
     @h2h_match.players << Player.new(attributes)
    end
  end

  def player_data(player_element, player_json)
    minutes_played = get_minutes_played(player_element)
    games_left = get_games_left(player_element)
    team_name = get_team_name(player_element)
    match_over = match_over?(team_name)
    name = get_player_name(player_element)
    captain = player_json['is_captain']
    points = player_json['event_points']
    position = case player_json['type']
               when 1 then "GK"
               when 2 then "DEF"
               when 3 then "MID"
               when 4 then "FWD"
               else
                 raise "Unknown player type"
               end

   {name: name, games_left: games_left, captain: captain, position: position, points: points, minutes_played: minutes_played, match_over: match_over}
  end

  def get_minutes_played(player_element)
    tooltip = player_element.at_css('.ismTooltip')['title']
    mp_node = Nokogiri::HTML(tooltip).search("[text()*='Minutes played']").first
    if mp_node
      minutes_played = mp_node.next_element.content.strip.to_i
    else
      minutes_played = 0
    end
  end

  def get_games_left(player_element)
    matches_or_points = player_element.at_css('.ismTooltip').content
    if matches_or_points.scan(/\d{1,}/).length > 0
      games_left = 0
    else
      games_left = matches_or_points.split(",").length
    end
  end

  def get_team_name(player_element)
    player_element.at_css('.ismShirt')['title'].strip
  end

  def get_player_name(player_element)
    player_element.at_css('.ismPitchWebName').content.strip
  end

  # If the match has started we can check the fixture details and figure
  # out if the match is over by looking for players with 90 minutes played.
  # The result is cached on the match object to avoid unnecessary parsing.
  # TODO: No good during DGW
  def match_over?(team_name)
    @match.pl_match_over ||= []
    fixture_info = @doc.at(".ismResult:contains('#{team_name}')")
    fixture_id = fixture_info.next_element.at_css('.ismFixtureStatsLink')['data-id'].to_i if(fixture_info)
    if fixture_id && @match.pl_match_over[fixture_id].blank?
      fixture_url = "http://fantasy.premierleague.com/fixture/#{fixture_id}/"
      fixture_data = Nokogiri::HTML(open(fixture_url))
      if fixture_data.content.blank?
        raise "Content is blank"
      end
      @match.pl_match_over[fixture_id] = (fixture_data.xpath("//td[2][contains(text(), '90')]").length > 2) # Checking that 90 exists 3 times to be safe
    end
    return fixture_id.present? ? @match.pl_match_over[fixture_id] : false
  end

end
