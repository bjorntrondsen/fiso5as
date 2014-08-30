class Team < ActiveRecord::Base
  has_many :managers, dependent: :destroy
  validates_presence_of :name, :fpl_id

  def fpl_url
    "http://fantasy.premierleague.com/my-leagues/#{fpl_id}/standings/"
  end
end
