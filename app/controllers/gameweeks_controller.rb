require 'nokogiri'
require 'open-uri'

class GameweeksController < ApplicationController
  def index
    @matches = []
    @matches << Match.new(home: Manager.new(fpl_id: 432374, name: 'Lovely_Camel'), away: Manager.new(fpl_id: 163959, name: 'malefice'))
  end
end

class Match
  attr_accessor :home, :away

  def initialize(args)
    @home = args[:home]
    @away = args[:away]
  end

  def home_ahead?
    home.score > away.score
  end

  def away_ahead?
    away.score > home.score
  end

  def score_diff
    away.score - home.score
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

class Manager
  attr_accessor :fpl_id, :name

  def initialize(args)
    @fpl_id = args[:fpl_id]
    @name = args[:name]
    @squad = []

    game_week = 1
    url = "http://fantasy.premierleague.com/entry/#{@fpl_id}/event-history/#{game_week}/"
    @doc = Nokogiri::HTML(open(url))

    set_squad
  end

  def score
    point_string = @doc.css('.ismSB .ismSBPrimary > div').first.content.strip
    point_string.scan(/\A\d*/).first.to_i
  end

  def remaining_players
    @squad.collect{|p| p.name if p.minutes_played == 0}.join(" ")
  end

  private

  def set_squad
    player_rows = @doc.css('#ismDataElements tr')
    #counter = 11
    player_rows.each do |row|
      name = row.css('td')[0].content
      minutes_played = row.css('td')[2].content.to_i
      score = row.css('td')[16].content.to_i
      @squad << Player.new(name: name, minutes_played: minutes_played, score: score)
      #counter += 1
      #break if counter == 0
    end
  end

end
