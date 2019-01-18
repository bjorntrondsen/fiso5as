require 'spec_helper'

describe Match do

  describe "#set_up_match!" do
    let(:eagle_fpl_ids) { [3194, 121565, 1164928, 2348, 8835] }
    let(:moderator_fpl_ids) { [45444, 29988, 155655, 886939, 26342] }
    let :match do
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
      home_team = Fabricate(:eagles)
      eagle_fpl_ids.each do |fpl_id|
        Manager.create!(fpl_id: fpl_id, team: home_team)
      end
      away_team = Fabricate(:moderators)
      moderator_fpl_ids.each do |fpl_id|
        Manager.create!(fpl_id: fpl_id, team: away_team)
      end
      match = Fabricate(:match, home_team: home_team, away_team: away_team, game_week: Fabricate(:game_week, gw_no: 2))
      VCR.use_cassette('set_up_teams') do
        expect { match.set_up_match! }.to_not change { Manager.count }
      end
    end

    it "should set the match order based on the current in-game order" do
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

    it "should add new entries" do
      VCR.use_cassette('falcons_new_entries') do
        eagles_fpl_id = 191334
        falcon_fpl_id = 5749
        match = Fabricate(:match, home_team: Fabricate(:team, fpl_id: 191334, name: 'Eagles'), away_team: Fabricate(:team, fpl_id: 5749, name: 'Falcons'), game_week: Fabricate(:game_week, gw_no: 23))
        match.set_up_match!(skip_fpl_sync: true)
        expect(match.away_team.managers.length).to eq(5)
        expect(match.h2h_matches.find_by!(match_order: 1).away_manager.fpl_id).to eq(1030017)
        expect(match.h2h_matches.find_by!(match_order: 2).away_manager.fpl_id).to eq(20049)
        expect(match.h2h_matches.find_by!(match_order: 3).away_manager.fpl_id).to eq(775013)
        expect(match.h2h_matches.find_by!(match_order: 4).away_manager.fpl_id).to eq(19613)
        expect(match.h2h_matches.find_by!(match_order: 5).away_manager.fpl_id).to eq(18060)
      end
    end
  end

end
