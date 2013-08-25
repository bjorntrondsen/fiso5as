class MatchesController < ApplicationController

  def index
    render text: 'Need a match ID'
  end

  def show
    @match = Match.includes(:home_team, :away_team, :h2h_matches).find(params[:id])
  end

end
