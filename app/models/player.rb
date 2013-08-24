class Player
  attr_accessor :manager, :name, :games_left, :captain, :position, :points, :minutes_played, :match_over

  def initialize(args)
    @name = args[:name]
    @games_left = args[:games_left]
    @captain = args[:captain]
    @position = args[:position]
    @manager = args[:manager]
    @points = args[:points]
    @minutes_played = args[:minutes_played]
    @match_over = args[:match_over]
  end

  def captain?
    @captain
  end

  def info
    str = ""
    if games_left > 1
      str += "#{games_left}x"
    end
    str += name.gsub(" ",'')
    if captain? && !manager.opponent.find_player(self.name)
      str += "(c)"
    end
    return str
  end

end
