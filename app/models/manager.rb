class Manager < ActiveRecord::Base
  validates_presence_of :fpl_id

  def fpl_url
    "http://fantasy.premierleague.com/entry/#{self.fpl_id}/event-history"
  end

  def name
    fiso_name || fpl_name
  end
end
