class GameWeek < ApplicationRecord
  has_many :matches, -> { order(:gw_fixture_no) }, dependent: :destroy

  validates_presence_of :season, :gw_no, :access_token, :deadline_at
  validates_uniqueness_of :access_token
  validates_uniqueness_of :gw_no, scope: :season

  before_validation :generate_access_token, on: :create
  before_validation :set_deadline, on: :create

  def self.ongoing
    where(finished: false).where('deadline_at < ?', Time.zone.now - 30.minutes)
  end

  def self.sync_open
    FplScraper.clear_cache
    raise "Something is wrong. Found #{ongoing.count} ongoing gameweeks" if ongoing.count > 2
    ongoing.each(&:fpl_sync)
  end

  def ongoing?
    !finished && (deadline_at + 30.minutes) < Time.zone.now
  end

  def name
    "Game week #{gw_no}"
  end

  def fpl_sync
    matches.each(&:fpl_sync)
    set_finished
  end

  def setup
    matches.each do |match|
      match.set_up_match!(skip_fpl_sync: true)
    end
  end

  private

  def generate_access_token
    self.access_token ||= (0...8).map{ ('A'..'Z').to_a[rand(26)] }.join
  end

  def set_deadline
    return if deadline_at.present?
    fpl_timestamp = fpl_data['deadline_time']
    self.deadline_at ||= Time.zone.parse(fpl_timestamp)
  end

  def set_finished
    self.finished = fpl_data['finished'] && fpl_data['data_checked']
    self.save!
  end

  def fpl_data
    FplScraper.static_data['events'].find{|x| x['name'] == "Gameweek #{gw_no}"}
  end
end
