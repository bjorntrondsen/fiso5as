class GameWeek < ApplicationRecord
  DEADLINE_PADDING = 30.minutes
  ACTIVATION_HOURS = 24

  has_many :matches, -> { order(:gw_fixture_no) }, dependent: :destroy

  validates_presence_of :season, :gw_no, :access_token, :deadline_at
  validates_uniqueness_of :access_token
  validates_uniqueness_of :gw_no, scope: :season

  before_validation :generate_access_token, on: :create
  before_validation :set_deadline, on: :create

  def self.active
    where(finished: false).where('deadline_at < ?', Time.zone.now + ACTIVATION_HOURS.hours)
  end

  def self.sync_open
    RailsExceptionHandler.catch do
      raise "Something is wrong. Found #{active.count} active gameweeks" if active.count > 2
      active.each do |game_week|
        game_week.set_up
        game_week.fpl_sync if game_week.ongoing?
      end
    end
  end

  def self.update_deadlines
    RailsExceptionHandler.catch do
      where(finished: false).each do |gw|
        gw.send(:set_deadline, force: true)
        gw.save!
      end
    end
  end

  def ongoing?
    !finished && (deadline_at + DEADLINE_PADDING) < Time.zone.now
  end

  def name
    "Game week #{gw_no}"
  end

  def set_up
    matches.each do |match|
      match.set_up_match!(skip_fpl_sync: true) if match.h2h_matches.count == 0
    end
  end

  def fpl_sync
    FplScraper.clear_cache
    time = Time.zone.now
    ActiveRecord::Base.transaction do
      matches.each(&:fpl_sync)
    end
    set_finished
    self.last_sync_took = Time.zone.now - time
    self.save
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

  def set_deadline(force: false)
    return if deadline_at.present? && !force
    fpl_timestamp = fpl_data['deadline_time']
    self.deadline_at = Time.zone.parse(fpl_timestamp)
  end

  def set_finished
    self.finished = fpl_data['finished'] && fpl_data['data_checked']
    self.save!
  end

  def fpl_data
    FplScraper.static_data['events'].find{|x| x['name'] == "Gameweek #{gw_no}"}
  end
end
