class MatchesController < ApplicationController
  def index
    competition_id = params[:competition_id] || 'PL'
    matches = MatchesService.get_matches(competition_id)
    render json: { matches: matches }
  end
end
