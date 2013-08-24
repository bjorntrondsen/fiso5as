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

  #TODO: Use .at_css when there's only one hit
  def fetch_data
    @squad = []
    gw_url = "#{@url}/#{$game_week}/"
    @match_over = []
    @doc = Nokogiri::HTML(open(gw_url))
    @doc.css('.ismPitch .ismPitchElement').each do |player_element|
      player_json = player_element['class'].sub('ismPitchElement','')

      tooltip = player_element.css('.ismTooltip').first['title']
      mp_node = Nokogiri::HTML(tooltip).search("[text()*='Minutes played']").first
      if mp_node
        minutes_played = mp_node.next_element.content.strip.to_i
      else
        minutes_played = 0
      end

      # If the match has started we can check the fixture details and figure
      # out if the match is over by looking for players with 90 minutes played.
      team_name = player_element.at_css('.ismShirt')['title'].strip
      puts team_name
      fixture_info = @doc.at(".ismResult:contains('#{team_name}')")
      fixture_id = fixture_info.next_element.at_css('.ismFixtureStatsLink')['data-id'].to_i if(fixture_info)
      if fixture_id && @match_over[fixture_id].blank?
        fixture_url = "http://fantasy.premierleague.com/fixture/#{fixture_id}/"
        fixture_data = Nokogiri::HTML(open(fixture_url))
        if fixture_data.content.blank?
          raise "Content is blank"
        end
        @match_over[fixture_id] = (fixture_data.xpath("//td[2][contains(text(), '90')]").length > 2) # Checking that 90 exists 3 times to be safe
      end

      match_over = fixture_id.present? ? @match_over[fixture_id] : false
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
      @squad << Player.new(name: name, games_left: games_left, captain: captain, position: position, points: points, minutes_played: minutes_played, match_over: match_over, manager: self)
    end
  end
end
