class GameWeeksController < ApplicationController
  def index
    @game_weeks = GameWeek.order(:gw_no)
  end
end
