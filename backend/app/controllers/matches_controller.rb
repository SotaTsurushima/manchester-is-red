class MatchesController < ApplicationController
  before_action :set_match, only: [:show]

  def index
    competition_id = params[:competition_id] || 'PL'
    page = params[:page].to_i > 0 ? params[:page].to_i : 1
    per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 10

    matches = Matches::MatchesService.get_matches(competition_id, page: page, per_page: per_page)
    render json: { matches: matches }
  end

  def show
    render json: { match: @match }
  end

  private

  def set_match
    @match = Match.find(params[:id])
  end
end
