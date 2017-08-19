class Manager < ActiveRecord::Base
  validates_presence_of :fpl_id

  def gw_url(gw)
    "https://fantasy.premierleague.com/a/team/#{fpl_id}/event/#{gw}"
  end

  def name
    fiso_name || fpl_name
  end
end
