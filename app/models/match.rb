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
    end
    puts "Done (match #{self.id}) #{Time.zone.now}"
  end

  def playing_now(side)
    differentiators(side, :playing_now)
  end

  def playing_later(side)
    differentiators(side, :playing_later)
  end

  private

  def differentiators(side, playing)
    player_names = h2h_matches.collect{|h2h| h2h.send(playing, side).collect{|player| player.name.gsub(' ', '')} }.flatten
    result = Hash.new(0)
    player_names.each { |name| result[name] += 1 }
    result.sort_by{|name,count| count }.reverse
  end

end
