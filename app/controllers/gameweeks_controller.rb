require 'nokogiri'
require 'open-uri'
require 'rufus-scheduler'

$game_week = 2

class GameweeksController < ApplicationController
  @@matches = []

  scheduler = Rufus::Scheduler.new
  scheduler.every '5m', blocking: true do
    get_matches
  end

  def index
    @matches = @@matches
  end

  private

  def self.get_matches
    puts "Getting match data #{Time.zone.now}"
    @@matches = []
    @@matches << Match.new(home: [470, 'Moist von Lipwig'], away: [735104,'Deanbarrono'])
    @@matches << Match.new(home: [629200, 'From4Corners'], away: [675948,'Wyld'])
    @@matches << Match.new(home: [785, 'From4Corners'], away: [32003,'travatron'])
    @@matches << Match.new(home: [187870, 'Sharagoz'], away: [603709,'Llama'])
    @@matches << Match.new(home: [432374, 'Lovely_Camel'], away: [555192,'Saturn XI'])
    puts "Done #{Time.zone.now}"
    return @@matches
  end

  get_matches
end
