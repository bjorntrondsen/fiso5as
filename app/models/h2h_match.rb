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
    fetch_data_for(home_manager, :home)
    fetch_data_for(away_manager, :away)
    self.save!
  end

  private

  #TODO: Use .at_css when there's only one hit
  def fetch_data_for(manager, side)
    match.pl_match_over ||= []
    gw_url = "#{manager.fpl_url}/#{self.match.game_week}/"
    @doc = Nokogiri::HTML(open(gw_url))
    score = @doc.css('.ismSB .ismSBPrimary > div').first.content.strip.scan(/\A\d{1,}/).first.to_i
    self.home_score = score if(side == :home)
    self.away_score = score if(side == :away)
    @doc.css('.ismPitch .ismPitchElement').each do |player_element|
      player_json = player_element['class'].sub('ismPitchElement','')

      tooltip = player_element.css('.ismTooltip').first['title']
      mp_node = Nokogiri::HTML(tooltip).search("[text()*='Minutes played']").first
      if mp_node
        minutes_played = mp_node.next_element.content.strip.to_i
      else
        minutes_played = 0
      end

      # If the match has started we can check the fixture details and figure
      # out if the match is over by looking for players with 90 minutes played.
      team_name = player_element.at_css('.ismShirt')['title'].strip
      fixture_info = @doc.at(".ismResult:contains('#{team_name}')")
      fixture_id = fixture_info.next_element.at_css('.ismFixtureStatsLink')['data-id'].to_i if(fixture_info)
      if fixture_id && match.pl_match_over[fixture_id].blank?
        fixture_url = "http://fantasy.premierleague.com/fixture/#{fixture_id}/"
        fixture_data = Nokogiri::HTML(open(fixture_url))
        if fixture_data.content.blank?
          raise "Content is blank"
        end
        match.pl_match_over[fixture_id] = (fixture_data.xpath("//td[2][contains(text(), '90')]").length > 2) # Checking that 90 exists 3 times to be safe
      end

      match_over = fixture_id.present? ? match.pl_match_over[fixture_id] : false
      name = player_element.css('.ismPitchWebName').first.content.strip
      player_json = JSON.parse(player_json)
      captain = player_json['is_captain']
      points = player_json['event_points']
      position = case player_json['type']
                 when 1 then "GK"
                 when 2 then "DEF"
                 when 3 then "MID"
                 when 4 then "FWD"
                 else
                   raise "Unknown player type"
                 end
      # Has point details, currently not in use
      #player_tooltip = player_element.css('.ismTooltip').first['title']
      matches_or_points = player_element.css('.ismTooltip').first.content
      if matches_or_points.scan(/\d{1,}/).length > 0
        games_left = 0
      else
        games_left = matches_or_points.split(",").length
      end
     self.players << Player.new(name: name, games_left: games_left, captain: captain, position: position, points: points, minutes_played: minutes_played, match_over: match_over, manager_id: manager.id)
    end
  end

  def differentiators(side)
    differentiators = []
    if side == :home
      my_players = players.where(manager_id: home_manager_id)
      their_players = players.where(manager_id: away_manager_id)
    end
    if side == :away
      my_players = players.where(manager_id: away_manager_id)
      their_players = players.where(manager_id: home_manager_id)
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
