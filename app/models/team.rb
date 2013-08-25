class Team < ActiveRecord::Base
  has_many :managers, dependent: :destroy
  validates_presence_of :name, :fpl_id
end
