require 'spec_helper'

describe Player do
  describe 'scopes' do
    example '#not_benched'do
      player1 = Fabricate(:player, bench: true)
      player2 = Fabricate(:player, bench: false)
      expect(Player.not_benched).to_not include(player1)
       expect(Player.not_benched).to include(player2)
    end

    example '#benched'do
      player1 = Fabricate(:player, bench: true)
      player2 = Fabricate(:player, bench: false)
      expect(Player.benched).to include(player1)
      expect(Player.benched).to_not include(player2)
    end
  end

  describe '#didnt_play'do
    it "should include a player whos match is over with 0 minutes played" do
      Fabricate(:player, matches_over: true, minutes_played: 0)
      expect(Player.didnt_play.count).to eq(1)
    end

    it "should_not include a player whos match isnt over" do
      Fabricate(:player, matches_over: false, minutes_played: 0)
      expect(Player.didnt_play).to eq([])
    end

    it "should_not include a player whos has minutes played" do
      Fabricate(:player, matches_over: true, minutes_played: 1)
      expect(Player.didnt_play).to eq([])
    end
  end

  describe '#might_play'do
    it "should include a player whos match isnt over" do
      Fabricate(:player, matches_over: false, minutes_played: 0)
      expect(Player.might_play.count).to eq(1)
    end

    it "should include a player who has minutes played" do
      Fabricate(:player, matches_over: true, minutes_played: 1)
      expect(Player.might_play.count).to eq(1)
    end

    it "should not include a player whos match is over with 0 minutes played" do
      Fabricate(:player, matches_over: true, minutes_played: 0)
      expect(Player.might_play.count).to eq(0)
    end
  end

  describe "positions" do
    before :each do
      @gk = Fabricate(:player, position: 'GK')
      @defe = Fabricate(:player, position: 'DEF')
      @mid = Fabricate(:player, position: 'MID')
      @fwd = Fabricate(:player, position: 'FWD')
    end

    example '#goal_keepers' do
      expect(Player.goal_keepers).to eq([@gk])
    end

    example '#defenders' do
      expect(Player.defenders).to eq([@defe])
    end

    example '#forwards' do
      expect(Player.forwards).to eq([@fwd])
    end

    example '#outfield_players' do
      expect(Player.outfield_players).to eq([@defe, @mid, @fwd])
    end
  end
end
