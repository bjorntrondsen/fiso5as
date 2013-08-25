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

end
