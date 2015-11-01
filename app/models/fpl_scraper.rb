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
    @doc = Nokogiri::HTML(gzip_fetch(gw_url))
    score = @doc.at_css('.ism-scoreboard-panel__points').content.strip.scan(/\A\d{1,}/).first.to_i
    @h2h_match.home_score = score if(side == :home)
    @h2h_match.away_score = score if(side == :away)
    @doc.css('.ismPitch .ismPitchElement, .ismBench .ismPitchElement').each do |player_element|
      json_str = player_element['class'].sub('ismPitchElement','')
      player_json = JSON.parse(json_str)
      attributes = player_data(player_element, player_json)
      attributes[:manager_id] = manager.id
     @h2h_match.players << Player.new(attributes)
    end
  end

  def player_data(player_element, player_json)
    name = get_player_name(player_element)
    team_name = get_team_name(player_json)
    minutes_played = get_minutes_played(player_element)
    games_left = get_games_left(player_element)
    match_over = match_over?(team_name)
    bench = benched?(player_element)
    captain = player_json['is_captain']
    vice_captain = player_json['is_vice_captain']
    points = player_json['event_points']
    position = case player_json['type']
               when 1 then "GK"
               when 2 then "DEF"
               when 3 then "MID"
               when 4 then "FWD"
               else
                 raise "Unknown player type"
               end

   {name: name, games_left: games_left, captain: captain, vice_captain: vice_captain, bench: bench, position: position, points: points, minutes_played: minutes_played, match_over: match_over}
  end

  def benched?(player_element)
    container = player_element.parent.parent.parent['class']
    if container == 'ismPitch'
      return false
    elsif container == 'ismBench'
      return true
    else
      raise "Unable to figure out of the player is on the pitch or on the bench"
    end
  end

  def get_minutes_played(player_element)
    tooltip = player_element.at_css('.ismTooltip')
    if tooltip && mp_node = Nokogiri::HTML(tooltip['title']).search("[text()*='Minutes played']").first
      minutes_played = mp_node.next_element.content.strip.to_i
    else
      minutes_played = 0
    end
  end

  def get_games_left(player_element)
    matches_or_points = player_element.at_css('.ismTooltip').try(:content)
    if matches_or_points == nil || matches_or_points.scan(/\d{1,}/).length > 0
      games_left = 0
    else
      games_left = matches_or_points.split(",").length
    end
  end

  def get_team_name(player_json)
    team_id = player_json['team']
    teams[team_id]
    #player_element.at_css('.ismShirt')['title'].strip
    #player_element.to_s.match(/title=\"(.*)\" class=\"ismShirt\"/)[1].strip
    #player_element.xpath("div/div/img")[0]['title']
  end

  def get_player_name(player_element)
    player_element.at_css('.ismPitchWebName').content.strip
  end

  # If the match has started we can check the fixture details and figure
  # out if the match is over by looking for players with 90 minutes played.
  # The result is cached on the match object to avoid unnecessary parsing.
  # TODO: No good during DGW
  def match_over?(team_name)
    Match.pl_match_over ||= {}
    return Match.pl_match_over[team_name] if !Match.pl_match_over[team_name].nil?
    if @doc.at(".ismFixtureTable:contains('#{team_name}')").blank? # No match
      return Match.pl_match_over[team_name] = true
    end
    fixture_info = @doc.at(".ismResult:contains('#{team_name}')")
    fixture_id = fixture_info.next_element.at_css('.ismFixtureStatsLink')['data-id'].to_i if(fixture_info)
    if fixture_id && Match.pl_match_over[team_name].blank?
      fixture_url = "http://fantasy.premierleague.com/fixture/#{fixture_id}/"
      fixture_data = Nokogiri::HTML(gzip_fetch(fixture_url))
      if fixture_data.content.blank?
        raise "Content is blank"
      end
      Match.pl_match_over[team_name] = (fixture_data.xpath("//td[2][contains(text(), '90')]").length > 2) # Checking that 90 exists 3 times to be safe
    end
    return fixture_id.present? ? Match.pl_match_over[team_name] : false
  end

  def teams
    return Match.teams if Match.teams
    Match.teams = []
    Match.teams[1] = 'Arsenal'
    Match.teams[2] = 'Aston Villa'
    Match.teams[3] = 'Bournemouth'
    Match.teams[4] = 'Chelsea'
    Match.teams[5] = 'Crystal Palace'
    Match.teams[6] = 'Everton'
    Match.teams[7] = 'Leicester'
    Match.teams[8] = 'Liverpool'
    Match.teams[9] = 'Man City'
    Match.teams[10] = 'Man Utd'
    Match.teams[11] = 'Newcastle'
    Match.teams[12] = 'Norwich'
    Match.teams[13] = 'Southampton'
    Match.teams[14] = 'Spurs'
    Match.teams[15] = 'Stoke'
    Match.teams[16] = 'Sunderland'
    Match.teams[17] = 'Swansea'
    Match.teams[18] = 'Watford'
    Match.teams[19] = 'West Brom'
    Match.teams[20] = 'West Ham'
    Match.teams
  end

  def gzip_fetch(url)
    gzipped_html = open(url, 'Accept-Encoding' => 'gzip')
    gz = Zlib::GzipReader.new(StringIO.new(gzipped_html.read))
    gz.read
  end

end
