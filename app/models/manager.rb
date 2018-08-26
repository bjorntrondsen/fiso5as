class Manager < ActiveRecord::Base
  belongs_to :team

  validates_presence_of :fpl_id, :team
  validates_uniqueness_of :fpl_id, scope: :team_id

  def gw_url(gw)
    "https://fantasy.premierleague.com/a/team/#{fpl_id}/event/#{gw}"
  end

  def name
    fiso_name || fpl_name
  end
end
