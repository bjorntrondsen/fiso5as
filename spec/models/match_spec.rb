# encoding: utf-8
require 'spec_helper'

describe Match do

  describe "#set_up_match!" do
    let(:eagle_fpl_ids) { [3194, 121565, 1164928, 2348, 8835] }
    let(:moderator_fpl_ids) { [29988, 45444, 155655, 886939, 26342] }

    it "should create new teams and players" do
      VCR.use_cassette('set_up_teams') do
        Match.new(home_team_id: 169066, away_team_id: 213779, game_week: 2, starts_at: '2017-09-19 11:45:00 UTC', ends_at: '2017-09-22 04:00:00 UTC').set_up_match!
        expect(Match.count).to eq(1)
        expect(Manager.count).to eq(10)
        expect(H2hMatch.count).to eq(5)
        expect(Player.count).to eq(150)
        expect(Match.first.home_team.name).to eq('FISO 5AS The Eagles')
        expect(Match.first.away_team.name).to eq('FISO 5AS Moderators')
        expect(Match.first.home_team.managers.first.name).to eq('Matt Dixon')
        expect(Match.first.away_team.managers.first.name).to eq('David Tonkin')
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
        match = Match.new(home_team_id: 169066, away_team_id: 213779, game_week: 2, starts_at: '2017-09-19 11:45:00 UTC', ends_at: '2017-09-22 04:00:00 UTC')
        expect { match.set_up_match! }.to_not change { Manager.count }
      end
    end

    it "should set the match order based on the current in-game order" do
      team = Fabricate(:team, fpl_id: 169066)
      eagle_fpl_ids.shuffle.each do |fpl_id|
        Manager.create!(fpl_id: fpl_id, team: team)
      end
      team = Fabricate(:team, fpl_id: 213779)
      moderator_fpl_ids.shuffle.each do |fpl_id|
        Manager.create!(fpl_id: fpl_id, team: team)
      end
      VCR.use_cassette('set_up_teams') do
        match = Match.new(home_team_id: 169066, away_team_id: 213779, game_week: 2, starts_at: '2017-09-19 11:45:00 UTC', ends_at: '2017-09-22 04:00:00 UTC')
        match.set_up_match!
        expect(H2hMatch.order(:match_order).collect { |h2h| h2h.home_manager.fpl_id }).to eq(eagle_fpl_ids)
        expect(H2hMatch.order(:match_order).collect { |h2h| h2h.away_manager.fpl_id }).to eq(moderator_fpl_ids)
      end
    end
  end

end
