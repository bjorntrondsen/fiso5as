# encoding: utf-8
require 'spec_helper'

describe Match do

  describe "#set_up_match!" do
    let(:eagle_fpl_ids) { [3194, 121565, 1164928, 2348, 8835] }
    let(:moderator_fpl_ids) { [45444, 29988, 155655, 886939, 26342] }
    let :match do
      Team.destroy_all # DatabaseCleaner broken?
      Fabricate(:match, home_team: Fabricate(:team, fpl_id: 169066), away_team: Fabricate(:team, fpl_id: 213779), game_week: Fabricate(:game_week, gw_no: 2))
    end

    it "should create new teams and players" do
      VCR.use_cassette('set_up_teams') do
        match.set_up_match!
        expect(Match.count).to eq(1)
        expect(Manager.count).to eq(10)
        expect(H2hMatch.count).to eq(5)
        expect(Player.count).to eq(150)
        expect(Match.first.home_team.managers.first.name).to eq('Matt Dixon')
        expect(Match.first.away_team.managers.first.name).to eq('Dave England')
      end
    end

    it "should re-use existing players" do
      team = Fabricate(:team, fpl_id: 169066, name: 'Eagles')
      eagle_fpl_ids.each do |fpl_id|
        Manager.create!(fpl_id: fpl_id, team: team)
      end
      team = Fabricate(:team, fpl_id: 213779, name: 'Moderators')
      moderator_fpl_ids.each do |fpl_id|
        Manager.create!(fpl_id: fpl_id, team: team)
      end
      VCR.use_cassette('set_up_teams') do
        expect { match.set_up_match! }.to_not change { Manager.count }
      end
    end

    it "should set the match order based on the current in-game order" do
      Team.destroy_all # DatabaseCleaner broken?
      home_team = Fabricate(:team, fpl_id: 169066)
      eagle_fpl_ids.shuffle.each do |fpl_id|
        home_team.managers.create!(fpl_id: fpl_id)
      end
      away_team = Fabricate(:team, fpl_id: 213779)
      moderator_fpl_ids.shuffle.each do |fpl_id|
        away_team.managers.create!(fpl_id: fpl_id)
      end
      match = Fabricate(:match, home_team: home_team, away_team: away_team, game_week: Fabricate(:game_week, gw_no: 2))
      VCR.use_cassette('set_up_teams') do
        expect { match.set_up_match! }.to_not change { Manager.count }
        expect(H2hMatch.order(:match_order).collect { |h2h| h2h.home_manager.fpl_id }).to eq(eagle_fpl_ids)
        expect(H2hMatch.order(:match_order).collect { |h2h| h2h.away_manager.fpl_id }).to eq(moderator_fpl_ids)
      end
    end
  end

end
