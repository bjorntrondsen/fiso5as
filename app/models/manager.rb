class Manager
  attr_accessor :fpl_id, :name

  def initialize(args)
    @fpl_id = args[:fpl_id]
    @name = args[:name]
    fetch_data
  end

  def score
    @score ||= @doc.css('.ismSB .ismSBPrimary > div').first.content.strip.scan(/\A\d{1,}/).first.to_i
  end

  def remaining_players
    @remaining_players ||= @squad.collect{|p| p.info if p.games_left > 0}
  end

  private

  def fetch_data
    @squad = []
    url = "http://fantasy.premierleague.com/entry/#{@fpl_id}/event-history/#{$game_week}/"
    @doc = Nokogiri::HTML(open(url))
    @doc.css('.ismPitch .ismPitchElement').each do |player_element|
      player_json = player_element['class'].sub('ismPitchElement','')
      captain = JSON.parse(player_json)['is_captain']
      # Has point details, currently not in use
      #player_tooltip = player_element.css('.ismTooltip').first['title']
      name = player_element.css('.ismPitchWebName').first.content.strip
      matches_or_points = player_element.css('.ismTooltip').first.content
      if matches_or_points.scan(/\d{1,}/).length > 0
        games_left = 0
      else
        games_left = matches_or_points.split(",").length
      end
      @squad << Player.new(name: name, games_left: games_left, captain: captain)
    end
  end
end
