class GameWeeksController < ApplicationController
  def index
    @game_weeks = GameWeek.order(:gw_no).includes(:matches)
  end
end
