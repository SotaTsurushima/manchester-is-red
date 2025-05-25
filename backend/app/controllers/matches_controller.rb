class MatchesController < ApplicationController
  def index
    competition_id = params[:competition_id] || 'PL'
    matches = Matches::MatchesService.get_matches(competition_id)
    render json: { matches: matches }
  end
end
