class Player < ActiveRecord::Base
  belongs_to :h2h_match
  belongs_to :manager

  def self.not_benched
    self.where(bench: false)
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
