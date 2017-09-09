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
        game_week = Fabricate(:game_week, gw_no: 2, finished: false, deadline_at: 1.day.ago)
        home = Fabricate(:manager, fpl_id: 1164928, fiso_name: 'Sharagoz')
        away = Fabricate(:manager, fpl_id: 8835, fiso_name: 'Moist von Lipwig')
        match = Fabricate(:match, game_week: game_week)
        h2h = match.h2h_matches.create!(home_manager_id: home.id, away_manager_id: away.id, match_order: 1)
        expect { GameWeek.sync_open }.to change { game_week.reload.finished }.to(true)
      end
    end

    describe 'match set up' do
      let!(:game_week) do
        Fabricate(:game_week, gw_no: 4, finished: false)
      end

      let!(:match) do
        home_team = Fabricate(:eagles)
        away_team = Fabricate(:moderators)
        Fabricate(:match, game_week: game_week, home_team: home_team, away_team: away_team)
      end

      it "should set up matches if there are less than 48 hours until the deadline" do
        game_week.update_attributes!(deadline_at: 47.hours.from_now)
        VCR.use_cassette('game_week_4_one_match') do
          expect { GameWeek.sync_open }.to change { match.h2h_matches.count }.from(0).to(5)
        end
      end

      it "should not set up matches if there are more than 48 hours until the deadline" do
        game_week.update_attributes!(deadline_at: 49.hours.from_now)
        VCR.use_cassette('game_week_4_one_match') do
          expect { GameWeek.sync_open }.to_not change { match.h2h_matches.count }
        end
      end

      it "should not set up matches that have already been set up" do
        game_week.update_attributes!(deadline_at: 47.hours.from_now)
        VCR.use_cassette('game_week_4_one_match') do
          match.set_up_match!(skip_fpl_sync: true)
          expect { GameWeek.sync_open }.to_not change { match.h2h_matches.count }
        end
      end
    end
  end
end
