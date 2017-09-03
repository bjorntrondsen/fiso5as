class GameWeek < ApplicationRecord
  has_many :matches, dependent: :destroy

  validates_presence_of :season, :gw_no, :access_key, :deadline_at
  validates_uniqueness_of :access_key
  validates_uniqueness_of :gw_no, scope: :season

  before_validation :generate_access_key, on: :create
  before_validation :set_deadline, on: :create

  def name
    "Game week #{gw_no}"
  end

  def fpl_sync
    matches.each(&:fpl_sync)
  end

  private

  def generate_access_key
    self.access_key ||= (0...8).map{ ('A'..'Z').to_a[rand(26)] }.join
  end

  def set_deadline
    return if deadline_at.present?
    fpl_timestamp = FplScraper.static_data['events'].find{|x| x['name'] == "Gameweek #{gw_no}"}['deadline_time']
    self.deadline_at ||= Time.zone.parse(fpl_timestamp)
  end
end
