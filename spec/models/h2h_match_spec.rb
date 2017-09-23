require 'spec_helper'

describe H2hMatch do
  let!(:h2h) do
    Fabricate(:h2h_match)
  end

  example 'sanity check' do
    expect(h2h.players.home.count).to eq(15)
    expect(h2h.players.away.count).to eq(15)
    expect(h2h.players.home.not_benched.pluck(:position).sort).to eq(['DEF','DEF','DEF','FWD','FWD','FWD','GK','MID','MID','MID','MID']) # 3-4-3
    expect { h2h.inform_of_pending_substitutions(:home) }.to_not change { h2h.info }
  end

  describe '#inform_of_pending_substitutions' do
    let(:squad) { h2h.players.home }

    it "replaces a defender with a midfielder when the first sub is a midfielder" do
      squad.midfielders.first.update_attributes(position: 'DEF') # Switch to 4-3-3
      expect(squad.not_benched.pluck(:position).sort).to eq(['DEF','DEF','DEF','DEF','FWD','FWD','FWD','GK','MID','MID','MID'])
      squad.benched[1].update_attributes(position: 'MID')
      squad.benched[3].update_attributes(position: 'DEF')
      expect(squad.benched.pluck(:position)).to eq(['GK','MID','DEF','DEF'])
      squad.defenders.first.update_attributes!(minutes_played: 0)
      expect { h2h.inform_of_pending_substitutions(:home) }.to change {
        h2h.info[:home]
      }.to(["#{squad.benched[1].name} (2pts) will replace #{squad.defenders.first.name}"])
      expect(h2h.extra_points_home).to eq(2)
    end

    it "replaces a midfielder with a forward when the first sub is a forward" do
      squad.forwards.first.update_attributes(position: 'DEF') # Switch to 4-4-2
      expect(squad.not_benched.pluck(:position).sort).to eq(['DEF','DEF','DEF','DEF','FWD','FWD','GK','MID','MID','MID','MID'])
      squad.benched[1].update_attributes(position: 'FWD')
      expect(squad.benched.pluck(:position)).to eq(['GK','FWD','DEF','MID'])
      squad.midfielders.first.update_attributes!(minutes_played: 0)
      expect { h2h.inform_of_pending_substitutions(:home) }.to change {
        h2h.info[:home]
      }.to(["#{squad.benched[1].name} (2pts) will replace #{squad.midfielders.first.name}"])
    end

    it "replaces a forward with a defender when the first sub is a defender" do
      expect(squad.benched.pluck(:position)).to eq(['GK','DEF','DEF','MID'])
      squad.forwards.first.update_attributes!(minutes_played: 0)
      expect { h2h.inform_of_pending_substitutions(:home) }.to change {
        h2h.info[:home]
      }.to(["#{squad.benched[1].name} (2pts) will replace #{squad.forwards.first.name}"])
    end

    it "should ignore benched players who didnt play" do
      expect(squad.benched.pluck(:position)).to eq(['GK','DEF','DEF','MID'])
      squad.forwards.first.update_attributes!(minutes_played: 0)
      squad.benched.second.update_attributes!(minutes_played: 0)
      squad.benched.third.update_attributes!(minutes_played: 0)
      expect { h2h.inform_of_pending_substitutions(:home) }.to change {
        h2h.info[:home]
      }.to(["#{squad.benched[3].name} (2pts) will replace #{squad.forwards.first.name}"])
    end

    it "should use the same substitute more than once" do
      expect(squad.benched.pluck(:position)).to eq(['GK','DEF','DEF','MID'])
      squad.forwards.first.update_attributes!(minutes_played: 0)
      squad.midfielders.first.update_attributes!(minutes_played: 0)
      expect { h2h.inform_of_pending_substitutions(:home) }.to change {
        h2h.info[:home]
      }.to([
        "#{squad.benched[1].name} (2pts) will replace #{squad.midfielders.first.name}",
        "#{squad.benched[2].name} (2pts) will replace #{squad.forwards.first.name}",
      ])
    end

    context 'special squad requirement rules' do
      context 'goal keepers' do
        it "should replace a goal keeper with a goal keeper" do
          goal_keepers = h2h.players.home.goal_keepers
          goal_keepers.first.update_attributes!(minutes_played: 0)
          expect { h2h.inform_of_pending_substitutions(:home) }.to change {
            h2h.info[:home]
          }.to(["#{goal_keepers.last.name} (2pts) will replace #{goal_keepers.first.name}"])
        end

        it "shouldnt replace the goal keeper with a goal keeper that didnt play" do
          goal_keepers = h2h.players.home.goal_keepers
          goal_keepers.update_all(minutes_played: 0)
          h2h.inform_of_pending_substitutions(:home)
          expect(h2h.info[:home]).to eq([])
        end
      end

      context 'defenders' do
        let(:squad) { h2h.players.home }

        before(:each) do
          squad.defenders.first.update_attributes!(minutes_played: 0)
          squad.benched[1].update_attributes(position: 'MID')
          squad.benched[3].update_attributes(position: 'DEF')
          expect(squad.not_benched.pluck(:position).sort).to eq(['DEF','DEF','DEF','FWD','FWD','FWD','GK','MID','MID','MID','MID'])
          expect(squad.benched.pluck(:position)).to eq(['GK','MID','DEF','DEF'])
        end

        it "should replace a defender with a defender 2nd on the bench if there are two playing defenders" do
          expect { h2h.inform_of_pending_substitutions(:home) }.to change {
            h2h.info[:home]
          }.to(["#{squad.benched[2].name} (2pts) will replace #{squad.defenders.first.name}"])
        end

        it "shouldnt replace a defender with a defender that didnt play" do
          squad.benched.defenders.update_all(minutes_played: 0)
          h2h.inform_of_pending_substitutions(:home)
          expect(h2h.info[:home]).to eq([])
        end
      end

      context 'forwards' do
        let(:squad) { h2h.players.away }

        before(:each) do
          # Switch to 4-5-1
          squad.forwards.first.update_attributes!(position: 'DEF')
          squad.forwards.second.update_attributes!(position: 'MID')
          squad.benched.third.update_attributes!(position: 'FWD')
          squad.benched.fourth.update_attributes!(position: 'FWD')
          expect(squad.not_benched.pluck(:position).sort).to eq(['DEF','DEF','DEF','DEF','FWD','GK','MID','MID','MID','MID','MID'])
          expect(squad.benched.pluck(:position)).to eq(['GK','DEF','FWD','FWD'])
        end

        it "should replace a forward with another foward 2nd on the bench if there are noe playing forwards" do
          squad.forwards.first.update_attributes!(minutes_played: 0)
          expect { h2h.inform_of_pending_substitutions(:away) }.to change {
            h2h.info[:away]
          }.to(["#{squad.benched[2].name} (2pts) will replace #{squad.forwards.first.name}"])
        end

        it "shouldnt replace a forward with a forward that didnt play" do
          squad.benched.forwards.update_all(minutes_played: 0)
          h2h.inform_of_pending_substitutions(:away)
          expect(h2h.info[:home]).to eq([])
        end
      end
    end
  end

  describe '#inform_of_pending_substitutions' do
    let(:squad) { h2h.players.home }

    it "should inform of captain change when the match is over and he didnt play" do
      squad.first.update_attributes(captain: true, minutes_played: 0, matches_over: true)
      squad.second.update_attributes(vice_captain: true, minutes_played: 90, matches_over: true, points: 3, bp_prediction: 1)
      expect { h2h.inform_of_captain_change(:home) }.to change {
        h2h.info[:home]
      }.to(["Armband will switch to #{squad.second.name} (4pts)"])
      expect(h2h.extra_points_home).to eq(4)
    end

    it "should not inform of armband change if the vice captain didnt change" do
      squad.first.update_attributes(captain: true, minutes_played: 0, matches_over: true)
      squad.second.update_attributes(vice_captain: true, minutes_played: 0, matches_over: true)
      expect { h2h.inform_of_captain_change(:home) }.to_not change { h2h.info[:home] }
    end
  end

  describe '#differentiators' do
    let(:home_squad) { h2h.players.home }
    let(:away_squad) { h2h.players.away}

    it "should include all non shared players" do
      expect(h2h.send(:differentiators, :home).length).to eq(11)
      expect(h2h.send(:differentiators, :away).length).to eq(11)
    end

    it "should remove shared players with the same fpl_id" do
      home_squad.first.update_attributes!(fpl_id: away_squad.first.fpl_id)
      home_squad.second.update_attributes!(fpl_id: away_squad.second.fpl_id)
      h2h.reload
      expect(h2h.send(:differentiators, :home).length).to eq(9)
      expect(h2h.send(:differentiators, :away).length).to eq(9)
    end

    it "should keep a shared player who is benched by the other side" do
      home_squad.first.update_attributes!(fpl_id: away_squad.last.fpl_id)
      h2h.reload
      expect(h2h.send(:differentiators, :home).length).to eq(11)
      expect(h2h.send(:differentiators, :away).length).to eq(11)
    end

    it "should include a shared player if he has the armband on one side" do
      home_squad.first.update_attributes!(fpl_id: away_squad.first.fpl_id, captain: true, multiplier: 2)
      h2h.reload
      expect(h2h.send(:differentiators, :home).length).to eq(11)
      expect(h2h.send(:differentiators, :away).length).to eq(10)
    end

    it "should not include a shared player if he has the armband on both sides" do
      home_squad.first.update_attributes!(fpl_id: away_squad.first.fpl_id, captain: true, multiplier: 2)
      away_squad.first.update_attributes!(captain: true, multiplier: 2)
      h2h.reload
      expect(h2h.send(:differentiators, :home).length).to eq(10)
      expect(h2h.send(:differentiators, :away).length).to eq(10)
    end

    it "should include a shared player if he is triple captain on one side and captain on the other" do
      home_squad.first.update_attributes!(fpl_id: away_squad.first.fpl_id, captain: true, multiplier: 3)
      away_squad.first.update_attributes!(captain: true, multiplier: 2)
      h2h.reload
      expect(h2h.send(:differentiators, :home).length).to eq(11)
      expect(h2h.send(:differentiators, :away).length).to eq(10)
    end
  end
end
