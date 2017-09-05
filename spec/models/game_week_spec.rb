# encoding: utf-8
require 'spec_helper'

describe GameWeek do
  it "should geneate a random access key on creation" do
    gw = GameWeek.create!(season: '201718', gw_no: 1, deadline_at: 1.week.from_now)
    expect(gw.access_token).to be_present
    expect(gw.access_token.length).to eq(8)
  end
end
