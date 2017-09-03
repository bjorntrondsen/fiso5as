class AddGwFixtureNoToMatches < ActiveRecord::Migration[5.1]
  def change
    add_column :matches, :gw_fixture_no, :integer
  end
end
