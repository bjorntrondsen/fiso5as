class Team < ActiveRecord::Base
  has_many :managers, dependent: :destroy
  validates_presence_of :name, :fpl_id

  def self.fpl_url(fpl_id)
    "https://fantasy.premierleague.com/drf/leagues-classic-standings/#{fpl_id}?phase=1&le-page=1&ls-page=1"
  end

  def fpl_url
    self.class.fpl_url(fpl_id)
  end

  def short_name
    name.sub('FISO', '').sub('5AS','').strip.titlecase
  end
end
