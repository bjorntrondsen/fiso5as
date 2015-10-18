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
    started? && !ended?
  end

  def set_up_match!
    require 'open-uri'

    teams = []
    [home_team_id, away_team_id].each do |team_id|
      team_url = "http://fantasy.premierleague.com/my-leagues/#{team_id}/standings/"
      doc = Nokogiri::HTML(open(team_url))
      doc = doc.at_css('section.ismPrimaryWide')
      team_name = doc.at_css("h2.ismTabHeading").content.sub("FISO 5AS",'').strip
      team = Team.create!(fpl_id: team_id, name: team_name)
      teams << team
      rows = doc.css('table.ismStandingsTable tr')
      "Expected 6 rows, got #{rows.length}" unless rows.length == 6
      rows.each do |row|
        unless row.children.first.name == 'th'
          cells = row.css('td')
          team_name = cells[2].content
          fpl_name = cells[3].content
          link = row.css('td a')[0].attributes['href'].value
          fpl_id = link.match(/entry\/(\d*)\/event-history/)[1]
          team.managers.create!(fpl_id: fpl_id, fpl_name: fpl_name)
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
