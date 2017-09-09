# encoding: utf-8
require 'spec_helper'

describe GameWeek do
  it "should geneate a random access key on creation" do
    gw = GameWeek.create!(season: '201718', gw_no: 1, deadline_at: 1.week.from_now)
    expect(gw.access_token).to be_present
    expect(gw.access_token.length).to eq(8)
  end

  describe "#sync_open" do
    it "should mark finished game weeks" do
      VCR.use_cassette('gw1_finished') do
        game_week = Fabricate(:game_week, gw_no: 2, finished: false)
        home = Fabricate(:manager, fpl_id: 1164928, fiso_name: 'Sharagoz')
        away = Fabricate(:manager, fpl_id: 8835, fiso_name: 'Moist von Lipwig')
        match = Fabricate(:match, game_week: game_week)
        h2h = match.h2h_matches.create!(home_manager_id: home.id, away_manager_id: away.id, match_order: 1)
        expect { GameWeek.sync_open }.to change { game_week.reload.finished }.to(true)
      end
    end
  end
end
