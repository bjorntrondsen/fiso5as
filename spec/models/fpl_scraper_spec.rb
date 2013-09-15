# encoding: utf-8
require 'spec_helper'

describe FplScraper do
  before :all do
    VCR.use_cassette('dgw_over') do
      @home = Manager.create!(fpl_id: 187870, fiso_name: 'Sharagoz')
      @away = Manager.create!(fpl_id: 470, fiso_name: 'Moist von Lipwig')
      @match = Match.make!(game_week: 1)
      @h2h = @match.h2h_matches.create!(home_manager_id: @home.id, away_manager_id: @away.id, match_order: 1)
      FplScraper.new(@h2h).scrape
    end
  end

  after :all do
    Match.destroy_all
  end

  it "creates players" do
    VCR.use_cassette('dgw_over') do
      Player.count.should eq(30)
    end
  end
end
