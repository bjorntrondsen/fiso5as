class Team < ActiveRecord::Base
  has_many :managers, dependent: :destroy
  validates_presence_of :name, :fpl_id

  def self.data_url(fpl_id)
    "https://fantasy.premierleague.com/drf/leagues-classic-standings/#{fpl_id}?phase=1&le-page=1&ls-page=1"
  end

  def fpl_url
    "https://fantasy.premierleague.com/a/leagues/standings/#{fpl_id}/classic"
  end

  def short_name
    name.sub('FISO', '').sub('5AS','').strip.titlecase
  end
end
