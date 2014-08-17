class Match < ActiveRecord::Base
  # Used to keep track of which prem league fixtures are finished when syncing data
  # Done for performance reasons
  attr_accessor :pl_match_over

  belongs_to :home_team, class_name: 'Team'
  belongs_to :away_team, class_name: 'Team'
  has_many :h2h_matches, dependent: :destroy

  def self.active
    self.where(["starts_at < ? AND ends_at > ?", Time.zone.now, Time.zone.now])
  end

  def fpl_sync
    puts "Getting FPL data (match #{self.id}) #{Time.zone.now}"
    transaction do
      h2h_matches.each{|m| m.fetch_data }
      self.touch
      self.save
    end
    puts "Done (match #{self.id}) #{Time.zone.now}"
  end

  def playing_now(side)
    differentiators(side, :playing_now)
  end

  def playing_later(side)
    differentiators(side, :playing_later)
  end

  def ended?
    Time.zone.now > ends_at
  end

  def started?
    Time.zone.now > starts_at
  end

  def ongoing?
    raise ends_at.inspect
    started? && !ended?
  end

  private

  def differentiators(side, playing)
    players_pr_match = h2h_matches.collect{|h2h| h2h.send(playing, side).collect{|player| [player.name.gsub(' ', ''), player.games_left]} }
    result = Hash.new(0)
    players_pr_match.each do |players|
      players.each do |name,matches_left|
        result[name] += matches_left
      end
    end
    result.sort_by{|name,count| count }.reverse
  end

end
