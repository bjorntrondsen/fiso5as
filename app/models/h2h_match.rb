require 'open-uri'

class H2hMatch < ActiveRecord::Base
  belongs_to :home_manager, class_name: 'Manager'
  belongs_to :away_manager, class_name: 'Manager'
  belongs_to :match, inverse_of: :game_week
  has_many :players, dependent: :destroy, autosave: true

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

  def predicted_home_score
    home_score + extra_points_home + bp_prediction(:home)
  end

  def predicted_away_score
    away_score + extra_points_away + bp_prediction(:away)
  end

  def home_ahead?
    predicted_home_score > predicted_away_score
  end

  def away_ahead?
    predicted_away_score > predicted_home_score
  end

  def score_diff
    (predicted_away_score - predicted_home_score).abs
  end

  def playing_now(side)
    differentiators(side).collect{|p| p if(p.playing_now?)}.compact
  end

  def playing_later(side)
    differentiators(side).collect{|p| p if(p.playing_later?)}.compact
  end

  def bp_prediction(side)
    send("#{side}_squad").inject(0){|sum,p| sum += p.bp_prediction unless p.bench; sum }
  end

  def bp_prediction_names(side)
    send("#{side}_squad").collect{|p| "#{p.name}:#{p.bp_prediction}" if p.bp_prediction > 0 && !p.bench }.compact.join(" ")
  end

  def fetch_data
    FplScraper.new(self).scrape
    self.save!
    set_defaults
    add_predictions!
    self.save!
  end

  def inform_of_pending_substitutions(side)
    squad = players.send(side)
    to_replace = squad.not_benched.didnt_play
    already_subed = []
    to_replace.each do |player|
      candidates = squad.might_play.benched
      if sub = find_sub(player,candidates,squad,already_subed)
        already_subed << sub
        if sub.playing_later?
          pts_str = ''
        else
          self.send("extra_points_#{side}=", self.send("extra_points_#{side}").send(:+, sub.points_with_bp))
          pts_str = " (#{sub.points_with_bp}pts)"
        end
        msg = "#{sub.name+pts_str} will replace #{player.name}"
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
        unless vice_captain.playing_later?
          msg += " (#{vice_captain.points_with_bp}pts)"
          self.send("extra_points_#{side}=", self.send("extra_points_#{side}").send(:+, vice_captain.points_with_bp))
        end
        self.info[side] << msg
      end
    end
  end

  def find_sub(player, candidates, squad, already_subed)
    if player.goal_keeper? # GK can only replace GK
      return candidates.goal_keepers.first
    elsif player.defender? && squad.not_benched.defenders.might_play.count < 3 # 3 DEFs required
      candidates = candidates.defenders
    elsif player.forward? && squad.forwards.not_benched.might_play.count == 0 # 1 FWD required
      candidates = candidates.forwards
    else # No special rule applies, take first sub
      candidates = candidates.outfield_players
    end
    unless already_subed.empty? # Dont use the same substitute more than once
      candidates = candidates.where.not(id: already_subed.collect(&:id))
    end
    return candidates.first
  end

  private

  def add_predictions!
    self.info = { home: [], away: [] }
    self.extra_points_home = 0
    self.extra_points_away = 0
    inform_of_pending_substitutions(:home)
    inform_of_pending_substitutions(:away)
    inform_of_captain_change(:home)
    inform_of_captain_change(:away)
  end

  def set_defaults
    self.home_score  ||= 0
    self.away_score  ||= 0
    self.info        = {home: [], away: []}
  end

  def differentiators(side)
    differentiators = []
    if side == :home
      my_players    = home_squad.collect { |p| p if p.bench == false }.compact
      their_players = away_squad.collect { |p| p if p.bench == false }.compact
    end
    if side == :away
      my_players    = away_squad.collect { |p| p if p.bench == false }.compact
      their_players = home_squad.collect { |p| p if p.bench == false }.compact
    end
    my_players.each do |my_player|
      their_player = their_players.find { |p| p.fpl_id == my_player.fpl_id }
      if !their_player  || (my_player.captain? && !their_player.captain?)
        differentiators << my_player
      end
    end
    return differentiators
  end
end
