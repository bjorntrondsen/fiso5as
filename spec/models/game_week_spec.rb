# encoding: utf-8
require 'spec_helper'

describe GameWeek do
  it "should geneate a random access key on creation" do
    gw = GameWeek.create!(season: '17/18', gw_no: 1)
    expect(gw.access_key).to be_present
    expect(gw.access_key.length).to eq(8)
  end
end
