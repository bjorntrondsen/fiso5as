class Player < ActiveRecord::Base
  belongs_to :h2h_match
  belongs_to :manager

  validates_inclusion_of :side, in: %w(home away)
  validates_presence_of :fpl_id
  validates_uniqueness_of :fpl_id, scope: [:h2h_match_id, :side]

  def self.home
    self.where(side: 'home')
  end

  def self.away
    self.where(side: 'away')
  end

  def self.not_benched
    self.where(bench: false)
  end

  def self.benched
    self.where(bench: true)
  end

  def self.didnt_play
    self.where(matches_over: true, minutes_played: 0)
  end

  def self.might_play
    self.where("minutes_played > 0 OR matches_over = false")
  end

  def self.goal_keepers
    self.where("position = 'GK'")
  end

  def self.forwards
    self.where("position = 'FWD'")
  end

  def self.midfielders
    self.where("position = 'MID'")
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
    minutes_played > 0 && matches_over == false
  end

  def playing_later?
    minutes_played == 0 && matches_over == false
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

  # TODO: Probably belongs in a decorator
  def info
    str = ""
    if games_left > 1
      str += "#{games_left}x"
    end
    str += name.gsub(" ",'')
    multiplier_diff = multiplier - (h2h_match.opposing_squad(self.manager_id).find{|p| p.fpl_id == self.fpl_id}&.multiplier || 0)
    if multiplier_diff == 2
      str += "(c)"
    elsif multiplier_diff == 3
      str += "(tc)"
    end
    return str
  end

  def compact_name
    name.gsub(' ', '')
  end

  def points_with_bp
    return nil unless points
    points + (bp_prediction || 0)
  end

end
