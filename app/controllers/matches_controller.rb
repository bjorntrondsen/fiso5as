class MatchesController < ApplicationController

  def index
    @game_week = (params[:game_week] || Match.started.order(:starts_at).last.game_week).to_i
    @matches = Match.where(game_week: @game_week).with_all_data.order(:id)
  end

  def show
    @match = Match.with_all_data.find(params[:id])
  end

  def new
    @match = Match.new(home_team_id: 169066, game_week: (Match.maximum(:game_week) || 0) + 1, starts_at: Time.zone.now.beginning_of_week.advance(days: 5, hours: 11, minutes: 45), ends_at: Time.zone.now.beginning_of_week.advance(days: 7, hours: 4))
  end

  def create
    @match = Match.new(match_params)
    @match.set_up_match!
    redirect_to @match
  end

  private

  def match_params
    params.require(:match).permit(:home_team_id, :away_team_id, :game_week, :starts_at, :ends_at)
  end

end
