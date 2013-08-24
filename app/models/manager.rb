class Manager
  attr_accessor :fpl_id, :url, :name, :squad, :opponent

  def initialize(args)
    @fpl_id = args[:fpl_id]
    @name = args[:name]
    @url = "http://fantasy.premierleague.com/entry/#{@fpl_id}/event-history"
    fetch_data
  end

  def score
    @score ||= @doc.css('.ismSB .ismSBPrimary > div').first.content.strip.scan(/\A\d{1,}/).first.to_i
  end

  def differentiators
    return @differentiators if @differentiators
    @differentiators = []
    @squad.each do |my_player|
      their_player = opponent.find_player(my_player.name)
      if my_player.games_left > 0  && (!their_player  || (my_player.captain? && !their_player.captain?))
        @differentiators << my_player
      end
    end
    return @differentiators
  end

  def find_player(name)
    @squad.find{|p| p.name == name}
  end

  private

  def fetch_data
    @squad = []
    gw_url = "#{@url}/#{$game_week}/"
    @doc = Nokogiri::HTML(open(gw_url))
    @doc.css('.ismPitch .ismPitchElement').each do |player_element|
      player_json = player_element['class'].sub('ismPitchElement','')
      name = player_element.css('.ismPitchWebName').first.content.strip
      player_json = JSON.parse(player_json)
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
      # Has point details, currently not in use
      #player_tooltip = player_element.css('.ismTooltip').first['title']
      matches_or_points = player_element.css('.ismTooltip').first.content
      if matches_or_points.scan(/\d{1,}/).length > 0
        games_left = 0
      else
        games_left = matches_or_points.split(",").length
      end
      @squad << Player.new(name: name, games_left: games_left, captain: captain, position: position, points: points, manager: self)
    end
  end
end
