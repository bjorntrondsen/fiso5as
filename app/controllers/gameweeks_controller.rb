require 'nokogiri'
require 'open-uri'
require 'rufus-scheduler'

$game_week = 2

class Match
  attr_accessor :home, :away

  def initialize(args)
    @home = Manager.new(fpl_id: args[:home][0], name: args[:home][1])
    @away = Manager.new(fpl_id: args[:away][0], name: args[:away][1])
  end

  def home_ahead?
    home.score > away.score
  end

  def away_ahead?
    away.score > home.score
  end

  def score_diff
    @score_diff ||= (away.score - home.score).abs
  end
end

class Manager
  attr_accessor :fpl_id, :name

  def initialize(args)
    @fpl_id = args[:fpl_id]
    @name = args[:name]
    fetch_data
  end

  def score
    @score ||= @doc.css('.ismSB .ismSBPrimary > div').first.content.strip.scan(/\A\d{1,}/).first.to_i
  end

  def remaining_players
    @remaining_players ||= @squad.collect{|p| p.info if p.games_left > 0}
  end

  private

  def fetch_data
    @squad = []
    url = "http://fantasy.premierleague.com/entry/#{@fpl_id}/event-history/#{$game_week}/"
    @doc = Nokogiri::HTML(open(url))
    @doc.css('.ismPitch .ismPitchElement').each do |player_element|
      player_json = player_element['class'].sub('ismPitchElement','')
      captain = JSON.parse(player_json)['is_captain']
      # Has point details, currently not in use
      #player_tooltip = player_element.css('.ismTooltip').first['title']
      name = player_element.css('.ismPitchWebName').first.content.strip
      matches_or_points = player_element.css('.ismTooltip').first.content
      if matches_or_points.scan(/\d{1,}/).length > 0
        games_left = 0
      else
        games_left = matches_or_points.split(",").length
      end
      @squad << Player.new(name: name, games_left: games_left, captain: captain)
    end
  end
end

class Player
  attr_accessor :name, :games_left, :captain

  def initialize(args)
    @name = args[:name]
    @games_left = args[:games_left]
    @captain = args[:captain]
  end

  def info
    str = ""
    if games_left > 1
      str += "#{games_left}x"
    end
    str += name.gsub(" ",'')
    if captain
      str += "(c)"
    end
    return str
  end

end

class GameweeksController < ApplicationController
  @@matches = []

  scheduler = Rufus::Scheduler.new
  scheduler.every '5m' do
    get_matches
  end

  def index
    @matches = @@matches
  end

  private

  def self.get_matches
    @@matches = []
    @@matches << Match.new(home: [470, 'Moist von Lipwig'], away: [735104,'Deanbarrono'])
    @@matches << Match.new(home: [785, 'McNulty'], away: [675948,'Wyld'])
    @@matches << Match.new(home: [629200, 'From4Corners'], away: [32003,'travatron'])
    @@matches << Match.new(home: [187870, 'Sharagoz'], away: [603709,'Llama'])
    @@matches << Match.new(home: [432374, 'Lovely_Camel'], away: [555192,'Saturn XI'])
    return @@matches
  end

  get_matches
end
