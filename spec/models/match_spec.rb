# encoding: utf-8
require 'spec_helper'

describe Match do

  describe "#set_up_match!" do
    example 'full stack test' do
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

  end

end
