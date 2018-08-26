class GameWeeksController < ApplicationController
  http_basic_authenticate_with name: "admin", password: ENV['http_basic_pw']

  def index
    @seasons = GameWeek.pluck(:season).uniq.sort
    @season = params[:season] || @seasons.last
    @game_weeks = GameWeek.where(season: @season).order(:gw_no).includes(matches: [:home_team, :away_team, :game_week])
  end
end
