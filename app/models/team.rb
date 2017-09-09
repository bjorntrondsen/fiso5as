class Team < ActiveRecord::Base
  has_many :managers, dependent: :destroy
  validates_presence_of :name, :fpl_id, :fiso_team_id
  validates_uniqueness_of :fpl_id

  def self.data_url(fpl_id)
    "https://fantasy.premierleague.com/drf/leagues-classic-standings/#{fpl_id}"
  end

  def fpl_url
    "https://fantasy.premierleague.com/a/leagues/standings/#{fpl_id}/classic"
  end

  def logo_path
    "2017_logos/#{fiso_team_id}.png"
  end

end
