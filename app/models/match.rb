require 'open-uri'

class Match < ActiveRecord::Base
  belongs_to :game_week, inverse_of: :matches
  belongs_to :home_team, class_name: 'Team'
  belongs_to :away_team, class_name: 'Team'
  has_many :h2h_matches, ->{ order('match_order ASC') }, dependent: :destroy

  validates_presence_of :game_week, :home_team, :away_team, :gw_fixture_no

  def self.active
    raise "No longer works"
    #self.where(["starts_at < ? AND ends_at > ?", Time.zone.now, Time.zone.now])
  end

  def self.started
    raise "No longer works"
    #where('starts_at < ?', Time.zone.now)
  end

  def self.with_all_data
    includes(:home_team, :away_team, :h2h_matches => [:players, :home_manager, :away_manager])
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

  def home_score
    h2h_matches.collect{|h| h if h.home_ahead? }.compact.length
  end

  def away_score
    h2h_matches.collect{|h| h if h.away_ahead? }.compact.length
  end

  def playing_now(side)
    differentiators(side, :playing_now)
  end

  def playing_later(side)
    differentiators(side, :playing_later)
  end

  def ended?
    game_week.finished
  end

  def started?
    Time.zone.now > game_week.deadline_at + GameWeek::DEADLINE_PADDING
  end

  def ongoing?
    started? && !ended?
  end

  def name
    "#{home_team.name} v #{away_team.name}"
  end

 def set_up_match!(skip_fpl_sync: false)
    ActiveRecord::Base.transaction do
      h2h = {
        home: managers_sorted_by_league_order(home_team),
        away: managers_sorted_by_league_order(away_team)
      }

      h2h[:home].each_with_index do|home_manager, index|
        self.h2h_matches.create!(home_manager: home_manager, away_manager: h2h[:away][index], match_order: index + 1)
      end

      fpl_sync unless skip_fpl_sync
    end
  end

 def managers_sorted_by_league_order(team)
   managers_sorted = []
   team_url = Team.data_url(team.fpl_id)
   team_data = JSON.parse(open(team_url).read)
   team_name = team_data['league']['name']
   team.name = team_name if team.name.blank?
   team.save!
   manager_data = team_data['standings']['results']
   raise "Expected 5 managers, found #{manager_data.length}" unless manager_data.length == 5
   manager_data.each do |data|
     manager = team.managers.find_or_initialize_by(fpl_id: data['entry'])
     manager.fpl_name = data['player_name'] if manager.fpl_name.blank?
     manager.save!
     managers_sorted << manager
   end
   managers_sorted
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
