class Match
  attr_accessor :home, :away

  def initialize(args)
    @home = Manager.new(fpl_id: args[:home][0], name: args[:home][1])
    @away = Manager.new(fpl_id: args[:away][0], name: args[:away][1])
    @home.opponent = @away
    @away.opponent = @home
  end

  def home_ahead?
    home.score > away.score
  end

  def away_ahead?
    away.score > home.score
  end

  def score_diff
    @score_diff ||= (away.score - home.score).abs
  end
end
