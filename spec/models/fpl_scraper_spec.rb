# encoding: utf-8
require 'spec_helper'

describe FplScraper do
  before :all do
    VCR.use_cassette('one_h2h_match') do
      @home = Manager.create!(fpl_id: 51639, fiso_name: 'Sharagoz')
      @away = Manager.create!(fpl_id: 1861, fiso_name: 'Moist von Lipwig')
      @match = Match.make!(game_week: 9)
      @h2h = @match.h2h_matches.create!(home_manager_id: @home.id, away_manager_id: @away.id, match_order: 1)
      FplScraper.new(@h2h).scrape
    end
  end

  after :all do
    Match.destroy_all
  end

  it "creates players" do
    VCR.use_cassette('one_h2h_match') do
      Player.count.should eq(30)
    end
  end
end
