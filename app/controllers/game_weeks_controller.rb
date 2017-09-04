class GameWeeksController < ApplicationController
  http_basic_authenticate_with name: "admin", password: ENV['http_basic_pw']

  def index
    @game_weeks = GameWeek.order(:gw_no).includes(:matches)
  end
end
