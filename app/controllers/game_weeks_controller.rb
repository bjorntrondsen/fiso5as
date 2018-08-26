class GameWeeksController < ApplicationController
  http_basic_authenticate_with name: "admin", password: ENV['http_basic_pw']

  def index
    current_season = GameWeek.pluck(:season).uniq.last
    @game_weeks = GameWeek.where(season: current_season).order(:gw_no).includes(matches: [:home_team, :away_team, :game_week])
  end
end
