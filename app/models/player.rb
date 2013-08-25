class Player < ActiveRecord::Base
  belongs_to :h2h_match
  belongs_to :manager

  def self.not_benched
    self.where(bench: false)
  end

  def self.benched
    self.where(bench: true)
  end

  def self.didnt_play
    self.where(match_over: true, minutes_played: 0)
  end

  def self.might_play
    self.where("(match_over=true AND minutes_played > 0) OR (match_over = false)")
  end

  def self.goal_keepers
    self.where("position = 'GK'")
  end

  def self.forwards
    self.where("position = 'FWD'")
  end

  def self.defenders
    self.where("position = 'DEF'")
  end

  def self.outfield_players
    self.where("position != 'GK'")
  end

  def captain?
    captain
  end

  def playing_now?
    minutes_played > 0 && match_over == false
  end

  def playing_later?
    games_left > 0
  end

  def goal_keeper?
    position == "GK"
  end

  def defender?
    position == "DEF"
  end

  def forward?
    position == "FWD"
  end

  def info
    str = ""
    if games_left > 1
      str += "#{games_left}x"
    end
    str += name.gsub(" ",'')
    if captain? #&& !manager.opponent.find_player(self.name)
      str += "(c)"
    end
    return str
  end

end
