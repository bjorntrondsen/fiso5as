class Player
  attr_accessor :name, :games_left, :captain

  def initialize(args)
    @name = args[:name]
    @games_left = args[:games_left]
    @captain = args[:captain]
  end

  def info
    str = ""
    if games_left > 1
      str += "#{games_left}x"
    end
    str += name.gsub(" ",'')
    if captain
      str += "(c)"
    end
    return str
  end

end
