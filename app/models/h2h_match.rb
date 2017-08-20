require 'open-uri'
class H2hMatch < ActiveRecord::Base
  belongs_to :home_manager, class_name: 'Manager'
  belongs_to :away_manager, class_name: 'Manager'
  belongs_to :match
  has_many :players, dependent: :destroy

  validates_presence_of :home_manager_id, :away_manager_id

  before_validation :set_defaults, on: :create

  serialize :info

  def home_squad
    @home_squad ||= players.collect { |p| p if p.side == 'home' }.compact
  end

  def away_squad
    @away_squad ||= players.collect { |p| p if p.side == 'away' }.compact
  end

  def opposing_squad(manager_id)
    if manager_id == home_manager_id
      away_squad
    elsif manager_id == away_manager_id
      home_squad
    else
      raise "Cant find the right manager"
    end
  end

  def home_ahead?
    home_score > away_score
  end

  def away_ahead?
    away_score > home_score
  end

  def score_diff
    (away_score - home_score).abs
  end

  def playing_now(side)
    differentiators(side).collect{|p| p if(p.playing_now?)}.compact
  end

  def playing_later(side)
    differentiators(side).collect{|p| p if(p.playing_later?)}.compact
  end

  def fetch_data
    self.players.destroy_all
    FplScraper.new(self).scrape
    self.save!
    set_defaults
    inform_of_pending_substitutions(:home)
    inform_of_pending_substitutions(:away)
    inform_of_captain_change(:home)
    inform_of_captain_change(:away)
    self.save!
  end

  def inform_of_pending_substitutions(side)
    squad = players.send(side)
    to_replace = squad.not_benched.didnt_play
    already_subed = []
    to_replace.each do |player|
      candidates = squad.might_play
      if sub = find_sub(player,candidates,squad,already_subed)
        already_subed << sub
        pts =  sub.playing_later? ? '' : " (#{sub.points}pts)"
        msg = "#{sub.name+pts} will replace #{player.name}"
        self.info[side] <<  msg
      end
    end
  end

  def inform_of_captain_change(side)
    squad = players.send(side)
    if squad.might_play.where(captain: true).count == 0
      vice_captain = squad.might_play.where(vice_captain: true).first
      if vice_captain
        msg = "Armband will switch to #{vice_captain.name}"
        msg += " (#{vice_captain.points}pts)" unless vice_captain.playing_later?
        self.info[side] << msg
      end
    end
  end

  def find_sub(player, candidates, squad, already_subed)
    if player.goal_keeper? # GK and only replace GK
      return candidates.goal_keepers.first
    elsif player.defender? && squad.not_benched.defenders.might_play.count < 3 # 3 defs required
      candidates = candidates.defenders.benched.might_play
    elsif player.forward? && squad.forwards.not_benched.might_play.count == 0 # 1 FWD required
      candidates = candidates.forwards.benched.might_play
    else # No special rule applies, take first sub
      candidates = candidates.outfield_players.benched.might_play
    end
    if !already_subed.empty?
      candidates.where!("players.id NOT IN (#{already_subed.collect{|p| p.id}.join(',')})")
    end
    return candidates.first
  end

  private

  def set_defaults
    self.home_score  ||= 0
    self.away_score  ||= 0
    self.info        = {home: [], away: []}
  end

  def differentiators(side)
    differentiators = []
    if side == :home
      my_players = home_squad.collect { |p| p if p.bench == false }.compact
      their_players = away_squad.collect { |p| p if p.bench == false }.compact
    end
    if side == :away
      my_players = away_squad.collect{ |p| p if p.bench == false }.compact
      their_players = home_squad.collect { |p| p if p.bench == false }.compact
    end
    my_players.each do |my_player|
      their_player = their_players.find{|p| p.name == my_player.name}
      if !their_player  || (my_player.captain? && !their_player.captain?)
        differentiators << my_player
      end
    end
    return differentiators
  end
end
