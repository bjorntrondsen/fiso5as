#
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

require 'open-uri'

class FplScraper

  def self.clear_cache
    @static_data = nil
    @live_data = nil
    @match_data = nil
    @bonus_added = nil
    @bp_prediction = nil
  end

  def self.static_data
    return @static_data if @static_data
    data_url = 'https://fantasy.premierleague.com/drf/bootstrap-static'
    @static_data = JSON.parse(open(data_url).read)
    @static_data
  end

  def self.live_data(game_week)
    @live_data ||= []
    return @live_data[game_week] if @live_data[game_week]
    data_url = "https://fantasy.premierleague.com/drf/event/#{game_week}/live"
    @live_data[game_week] = JSON.parse(open(data_url).read)
    @live_data[game_week]
  end

  def self.match_data(match_id, game_week)
    @match_data ||= []
    return @match_data[match_id] if @match_data[match_id]
    @match_data[match_id] = live_data(game_week)['fixtures'].find { |m| m['id'] == match_id }
  end

  def self.bonus_added?(match_id, game_week)
    @bonus_added ||= []
    return @bonus_added[match_id] if @bonus_added[match_id]
    bonus = @bonus_added[match_id] = match_data(match_id, game_week)['stats'].find{|s| s['bonus'] && (s['bonus']['a'].present? || s['bonus']['h'].present?) }
    @bonus_added[match_id] = bonus.present?
  end

  def self.bp_prediction(match_id, game_week)
    @bp_prediction ||= []
    return @bp_prediction[match_id] if @bp_prediction[match_id]
    bps_data = match_data(match_id, game_week)['stats'].find{|s| s['bps'] && (s['bps']['a'].present? || s['bps']['h'].present?) }
    @bp_prediction[match_id] = bps_data.present? ? BonusPointPredictor.predict(bps_data) : {}
  end

  def initialize(h2h_match)
    @h2h_match = h2h_match
    @match = h2h_match.match
    @game_week = @match.game_week.gw_no
  end

  def scrape
    fetch_data(@h2h_match.home_manager, :home)
    fetch_data(@h2h_match.away_manager, :away)
  end

  private

  def fetch_data(manager, side)
    picks_url = "https://fantasy.premierleague.com/drf/entry/#{manager.fpl_id}/event/#{@game_week}/picks"
    picks_data = JSON.parse open(picks_url).read
    active_chip = picks_data['active_chip']
    @h2h_match.send("#{side}_chip=",  active_chip)
    #score = picks_data['entry_history']['points']
    score = 0
    picks_data['picks'].each do |player_json|
      attributes = player_data(player_json)
      attributes[:manager_id] = manager.id
      attributes[:side] = side.to_s
      saved_player = @h2h_match.players.find{|p| p.side == side.to_s && p.name == attributes[:name] }
      saved_player ||= @h2h_match.players.new
      saved_player.attributes = attributes
      score += saved_player.points unless saved_player.bench
    end
    @h2h_match.home_score = score if(side == :home)
    @h2h_match.away_score = score if(side == :away)
  end

  def player_data(player_json)
    player_id       = player_json['element']
    player_details  = player_details(player_id)
    match_id        = player_details[:live]['explain'][0][1]
    multiplier      = player_json['multiplier']
    name            = get_player_name(player_details)
    team_name       = get_team_name(player_details)
    minutes_played  = get_minutes_played(player_details)
    games_left      = get_games_left(match_id)
    matches_over    = matches_over?(match_id)
    bench           = player_json['position'] > 11 # TODO: Bench boost handling
    captain         = player_json['is_captain']
    vice_captain    = player_json['is_vice_captain']
    points          = multiplier * get_points(player_details)
    position        = get_position(player_details)
    bp_prediction   = self.class.bp_prediction(match_id, @game_week)[player_id] || 0
    bp_prediction   = 0 if self.class.bonus_added?(match_id, @game_week) || match_minutes?(match_id) < 44

   { name: name, games_left: games_left, captain: captain, vice_captain: vice_captain, bench: bench, position: position, points: points, minutes_played: minutes_played, matches_over: matches_over, bp_prediction: bp_prediction }
  end

  def get_minutes_played(player_details)
    player_details[:live]['stats']['minutes']
  end

  # TODO: DGW not handled
  def get_games_left(match_id)
    matches_over?(match_id) ? 0 : 1
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

  def match_minutes?(match_id)
    self.class.match_data(match_id, @game_week)['minutes']
  end

  def match_started?(match_id)
    self.class.match_data(match_id, @game_week)['started']
  end

  def matches_over?(match_id)
    self.class.match_data(match_id, @game_week)['finished'] || self.class.match_data(match_id, @game_week)['finished_provisional']
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
