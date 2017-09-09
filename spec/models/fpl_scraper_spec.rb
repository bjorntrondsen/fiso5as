require 'spec_helper'

describe FplScraper do
  describe 'saving player data' do
    before :each do
      VCR.use_cassette('one_h2h_match') do
        home = Fabricate(:manager, fpl_id: 1164928, fiso_name: 'Sharagoz')
        away = Fabricate(:manager, fpl_id: 8835, fiso_name: 'Moist von Lipwig')
        match = Fabricate(:match, game_week: Fabricate(:game_week, gw_no: 2))
        h2h = match.h2h_matches.create!(home_manager_id: home.id, away_manager_id: away.id, match_order: 1)
        FplScraper.new(h2h).scrape
        match.save! # Trigger autosave
      end
    end

    let(:player_fields) { %w(captain vice_captain bench position points minutes played matches_over) }

    it "creates players" do
      VCR.use_cassette('one_h2h_match') do
        expect(Player.count).to eq(30)
      end
    end

    example 'player who has played' do
      player = Player.find_by(name: 'Foster')
      expect(player.attributes.slice(*player_fields)).to eq({
        "captain"=>false,
        "vice_captain"=>false,
        "bench"=>false,
        "position"=>"GK",
        "points"=>6,
        "matches_over"=>true
      })
    end

    example 'player who hasnt played' do
      player = Player.find_by(name: 'Danilo')
      expect(player.attributes.slice(*player_fields)).to eq({
        "captain"=>false,
        "vice_captain"=>false,
        "bench"=>false,
        "position"=>"DEF",
        "points"=>0,
        "matches_over"=>false
      })
    end

    example 'player with ongoing game'

    example 'captain' do
      player = Player.find_by(name: 'Lukaku')
      expect(player.attributes.slice(*player_fields)).to eq({
        "captain"=>true,
        "vice_captain"=>false,
        "bench"=>false,
        "position"=>"FWD",
        "points"=>12,
        "matches_over"=>true
      })
    end

    example 'vice captain' do
      player = Player.find_by(name: 'Kane')
      expect(player.attributes.slice(*player_fields)).to eq({
        "captain"=>false,
        "vice_captain"=>true,
        "bench"=>false,
        "position"=>"FWD",
        "points"=>0,
        "matches_over"=>false
      })
    end
  end

  it "should log chip info" do
    VCR.use_cassette('wildcarded_player') do
      home = Fabricate(:manager, fpl_id: 170949, fiso_name: 'Bob Newheart')
      away = Fabricate(:manager, fpl_id: 8835, fiso_name: 'Moist von Lipwig')
      match = Fabricate(:match, game_week: Fabricate(:game_week, gw_no: 4))
      h2h = match.h2h_matches.create!(home_manager: home, away_manager: away, match_order: 1)
      FplScraper.new(h2h).scrape
      expect(h2h.home_chip).to eq('wildcard')
      expect(h2h.away_chip).to eq('')
    end
  end
end
