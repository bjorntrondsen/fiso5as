class Player
  attr_accessor :name, :games_left, :captain, :manager

  def initialize(args)
    @name = args[:name]
    @games_left = args[:games_left]
    @captain = args[:captain]
    @manager = args[:manager]
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
