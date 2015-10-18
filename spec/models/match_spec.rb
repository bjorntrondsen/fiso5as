# encoding: utf-8
require 'spec_helper'

describe Match do

  describe "#set_up_match!" do
    example 'full stack test' do
      VCR.use_cassette('gw_halftime') do
        time = Time.zone.now

        Match.new(home_team_id: 16137, away_team_id: 30508, game_week: 1, starts_at: '2015-10-17 11:45:00 UTC', ends_at: '2015-10-19 04:00:00 UTC').set_up_match!

        expect(Match.count).to eq(1)
        expect(Manager.count).to eq(10)
        expect(H2hMatch.count).to eq(5)
        expect(Player.count).to eq(150)
        expect(Match.first.home_team.name).to eq('The Eagles')
        expect(Match.first.away_team.name).to eq('Wild Force')
        puts Time.zone.now - time
      end
    end
  end

end
