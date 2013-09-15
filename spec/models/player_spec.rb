# encoding: utf-8
require 'spec_helper'

describe Player do
  describe 'scopes' do
    example '#not_benched'do
      player1 = Player.make!(bench: true)
      player2 = Player.make!(bench: false)
      Player.not_benched.should_not include(player1)
      Player.not_benched.should include(player2)
    end

    example '#benched'do
      player1 = Player.make!(bench: true)
      player2 = Player.make!(bench: false)
      Player.benched.should include(player1)
      Player.benched.should_not include(player2)
    end
  end

  describe '#didnt_play'do
    it "should include a player whos match is over with 0 minutes played" do
      Player.make!(match_over: true, minutes_played: 0)
      Player.didnt_play.count.should eq(1)
    end

    it "should_not include a player whos match isnt over" do
      Player.make!(match_over: false, minutes_played: 0)
      Player.didnt_play.should eq([])
    end

    it "should_not include a player whos has minutes played" do
      Player.make!(match_over: true, minutes_played: 1)
      Player.didnt_play.should eq([])
    end
  end

  describe '#might_play'do
    it "should include a player whos match isnt over" do
      Player.make!(match_over: false, minutes_played: 0)
      Player.might_play.count.should eq(1)
    end

    it "should include a player who has minutes played" do
      Player.make!(match_over: true, minutes_played: 1)
      Player.might_play.count.should eq(1)
    end

    it "should not include a player whos match is over with 0 minutes played" do
      Player.make!(match_over: true, minutes_played: 0)
      Player.might_play.count.should eq(0)
    end
  end

  describe "positions" do
    before :each do
      @gk = Player.make!(position: 'GK')
      @defe = Player.make!(position: 'DEF')
      @mid = Player.make!(position: 'MID')
      @fwd = Player.make!(position: 'FWD')
    end

    example '#goal_keepers' do
      Player.goal_keepers.should eq([@gk])
    end

    example '#defenders' do
      Player.defenders.should eq([@defe])
    end

    example '#forwards' do
      Player.forwards.should eq([@fwd])
    end

    example '#outfield_players' do
      Player.outfield_players.should eq([@defe, @mid, @fwd])
    end
  end
end
