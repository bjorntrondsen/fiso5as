class GameWeek < ApplicationRecord
  has_many :matches, dependent: :destroy

  validates_presence_of :season, :gw_no, :access_key, :deadline_at
  validates_uniqueness_of :access_key
  validates_uniqueness_of :gw_no, scope: :season

  before_validation :generate_access_key, on: :create

  private

  def generate_access_key
    self.access_key ||= (0...8).map{ ('A'..'Z').to_a[rand(26)] }.join
  end
end
