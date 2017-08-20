# FPL JSON API
#
# JSON API

# Liga data:
# https://fantasy.premierleague.com/drf/leagues-classic-standings/169066?phase=1&le-page=1&ls-page=1
#
# Managerdata
# https://fantasy.premierleague.com/drf/entry/121565
#
# GW data
# https://fantasy.premierleague.com/drf/entry/121565/event/2/picks
#
# Live match data:
# https://fantasy.premierleague.com/drf/event/2/live
# Har info om alle kampene (20stk) og poengene spillerene (515stk)
#
# Statiske data:
# https://fantasy.premierleague.com/drf/bootstrap-static
# Laginfo, spillerinfo m.m
#
# Diverse
# https://fantasy.premierleague.com/drf/bootstrap-dynamic
# Match info, labels
# Viser om kamper er over

class FplScraper

  def self.clear_cache
    @static_data = nil
    @live_data = nil
  end

  def self.static_data
    return @static_data if @static_data
    data_url = 'https://fantasy.premierleague.com/drf/bootstrap-static'
    @static_data = JSON.parse(open(data_url).read)
    @static_data
  end

  def self.live_data(game_week)
    return @live_data if @live_data
    data_url = "https://fantasy.premierleague.com/drf/event/#{game_week}/live"
    @live_data = JSON.parse(open(data_url).read)
    @live_data
  end

  def initialize(h2h_match)
    @h2h_match = h2h_match
    @match = h2h_match.match
    @game_week = @match.game_week
  end

  def scrape
    fetch_data(@h2h_match.home_manager, :home)
    fetch_data(@h2h_match.away_manager, :away)
  end

  private

  def fetch_data(manager, side)
    picks_url = "https://fantasy.premierleague.com/drf/entry/#{manager.fpl_id}/event/#{@match.game_week}/picks"
    picks_data = JSON.parse open(picks_url).read
    score = picks_data['entry_history']['points']
    @h2h_match.home_score = score if(side == :home)
    @h2h_match.away_score = score if(side == :away)
    picks_data['picks'].each do |player_json|
      attributes = player_data(player_json)
      attributes[:manager_id] = manager.id
      attributes[:side] = side.to_s
      @h2h_match.players << Player.new(attributes)
    end
  end

  def player_data(player_json)
    player_id = player_json['element']
    player_details = player_details(player_id)
    name            = get_player_name(player_details)
    team_name       = get_team_name(player_details)
    minutes_played  = get_minutes_played(player_details)
    games_left      = get_games_left(player_details)
    match_over      = match_over?(player_details)
    bench           = player_json['position'] > 11 # TODO: Verify
    captain         = player_json['is_captain']
    vice_captain    = player_json['is_vice_captain']
    points          = get_points(player_details)
    position        = get_position(player_details)

   { name: name, games_left: games_left, captain: captain, vice_captain: vice_captain, bench: bench, position: position, points: points, minutes_played: minutes_played, match_over: match_over }
   
  end

  def get_minutes_played(player_details)
    player_details[:live]['stats']['minutes']
  end

  # TODO: DGW not handled
  def get_games_left(player_details)
    match_started?(player_details) ? 0 : 1
  end

  def get_team_name(player_details)
    self.class.static_data['teams'].find{|t| t['code'] == player_details[:static]['team_code']}['name']
  end

  def get_player_name(player_details)
    #player_details[:static]['first_name'] + " " + player_details[:static]['second_name']
    player_details[:static]['web_name']
  end

  def get_position(player_details)
    case player_details[:static]['element_type']
    when 1 then "GK"
    when 2 then "DEF"
    when 3 then "MID"
    when 4 then "FWD"
    else
      raise "Unknown element type: #{player_details[:static]['element_type'].inspect} for player named #{name}"
    end
  end

  def get_points(player_details)
    player_details[:live]['stats']['total_points']
  end

  def match_started?(player_details)
    match_id = player_details[:live]['explain'][0][1]
    self.class.live_data(@game_week)['fixtures'].find{|m| m['id'] == match_id }['started']
  end

  def match_over?(player_details)
    match_id = player_details[:live]['explain'][0][1]
    self.class.live_data(@game_week)['fixtures'].find{|m| m['id'] == match_id }['finished']
  end

  def gzip_fetch(url)
    gzipped_html = open(url, 'Accept-Encoding' => 'gzip')
    gz = Zlib::GzipReader.new(StringIO.new(gzipped_html.read))
    gz.read
  end

  def player_details(player_id)
    {
      static: self.class.static_data['elements'].find{|p| p['id'] == player_id},
      live: self.class.live_data(@game_week)['elements'][player_id.to_s]
    }
  end

end
