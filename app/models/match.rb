class Match < ActiveRecord::Base
  class << self
    # Fields used for caching when syncing to prevent unnecessary scraping
    attr_accessor :pl_match_over, :teams
  end

  belongs_to :home_team, class_name: 'Team'
  belongs_to :away_team, class_name: 'Team'
  has_many :h2h_matches, ->{ order('match_order ASC') }, dependent: :destroy

  def self.active
    self.where(["starts_at < ? AND ends_at > ?", Time.zone.now, Time.zone.now])
  end

  def self.started
    where('starts_at < ?', Time.zone.now)
  end

  def self.with_all_data
    includes(:home_team, :away_team, :h2h_matches => [:players, :home_manager, :away_manager])
  end

  def self.sync_all
    FplScraper.clear_cache
    self.pl_match_over = nil
    self.teams = nil
    time = Time.zone.now
    active.each{|m| m.fpl_sync }
    puts Time.zone.now - time
  end

  def fpl_sync
    time = Time.zone.now
    transaction do
      h2h_matches.each{|m| m.fetch_data }
      self.touch
      self.save
    end
    puts "Done (match #{self.id}) Took #{Time.zone.now - time}"
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
    started? && !ended?
  end

  def set_up_match!
    require 'open-uri'
    teams = []
    ActiveRecord::Base.transaction do
      [home_team_id, away_team_id].each do |team_id|
        team_url = Team.data_url(team_id)
        team_data = JSON.parse(open(team_url).read)
        team_name = team_data['league']['name']
        team = Team.create!(fpl_id: team_id, name: team_name)
        teams << team
        player_data = team_data['standings']['results']
        raise "Expected 5 players, found #{player_data.length}" unless player_data.length == 5
        player_data.each do |player|
          team.managers.create!(fpl_id: player['entry'], fpl_name: player['player_name'])
        end
      end
    end

    self.home_team = teams[0]
    self.away_team = teams[1]

    self.save!

    self.h2h_matches.create!(home_manager: home_team.managers[0], away_manager: away_team.managers[0], match_order: 1)
    self.h2h_matches.create!(home_manager: home_team.managers[1], away_manager: away_team.managers[1], match_order: 2)
    self.h2h_matches.create!(home_manager: home_team.managers[2], away_manager: away_team.managers[2], match_order: 3)
    self.h2h_matches.create!(home_manager: home_team.managers[3], away_manager: away_team.managers[3], match_order: 4)
    self.h2h_matches.create!(home_manager: home_team.managers[4], away_manager: away_team.managers[4], match_order: 5)

    fpl_sync
  end

  private

  def differentiators(side, playing)
    players_pr_match = h2h_matches.collect{|h2h| h2h.send(playing, side).collect{|player| [player.compact_name, player.games_left]} }
    result = Hash.new(0)
    players_pr_match.each do |players|
      players.each do |name,matches_left|
        result[name] += matches_left
      end
    end
    result.sort_by{|name,count| count }.reverse
  end

end
