require 'open-uri'
class H2hMatch < ActiveRecord::Base
  belongs_to :home_manager, class_name: 'Manager'
  belongs_to :away_manager, class_name: 'Manager'
  belongs_to :match
  has_many :players, dependent: :destroy

  validates_presence_of :home_manager_id, :away_manager_id

  def self.by_match_order
    self.order("match_order ASC")
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
  end


  private


  def differentiators(side)
    differentiators = []
    if side == :home
      my_players = players.not_benched.where(manager_id: home_manager_id)
      their_players = players.not_benched.where(manager_id: away_manager_id)
    end
    if side == :away
      my_players = players.not_benched.where(manager_id: away_manager_id)
      their_players = players.not_benched.where(manager_id: home_manager_id)
    end
    my_players.each do |my_player|
      their_player = their_players.find_by(name: my_player.name)
      if !their_player  || (my_player.captain? && !their_player.captain?)
        differentiators << my_player
      end
    end
    return differentiators
  end
end
