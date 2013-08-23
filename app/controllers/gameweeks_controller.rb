require 'nokogiri'
require 'open-uri'
require 'rufus-scheduler'

$game_week = 1

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
    @score ||= @doc.css('.ismSB .ismSBPrimary > div').first.content.strip.scan(/\A\d*/).first.to_i
  end

  def remaining_players
    @remaining_players ||= @squad.collect{|p| p.name if p.minutes_played == 0}.join(" ")
  end

  private

  def fetch_data
    @squad = []
    url = "http://fantasy.premierleague.com/entry/#{@fpl_id}/event-history/#{$game_week}/"
    @doc = Nokogiri::HTML(open(url))
    player_rows = @doc.css('#ismDataElements tr')
    player_rows.each do |row|
      name = row.css('td')[0].content
      minutes_played = row.css('td')[2].content.to_i
      score = row.css('td')[16].content.to_i
      @squad << Player.new(name: name, minutes_played: minutes_played, score: score)
    end
  end
end

class Player
  attr_accessor :name, :score, :minutes_played

  def initialize(args)
    @name = args[:name]
    @score = args[:score]
    @minutes_played = args[:minutes_played]
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
    puts "Refreshing match data"
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
