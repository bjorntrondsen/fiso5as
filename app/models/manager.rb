class Manager < ActiveRecord::Base
  belongs_to :team

  validates_presence_of :fpl_id, :team
  validates_uniqueness_of :fpl_id, scope: :team_id

  def gw_url(gw)
    "https://fantasy.premierleague.com/a/team/#{fpl_id}/event/#{gw}"
  end

  def fpl_data
    url = "https://fantasy.premierleague.com/drf/entry/#{fpl_id}"
    @fpl_data ||= JSON.parse(open(url).read)
  end

  def name
    fiso_name || fpl_name
  end

  def points_total
    fpl_data['entry']['summary_overall_points']
  end

end
