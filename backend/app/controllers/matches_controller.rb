class MatchesController < ApplicationController
  def index
    matches_data = fetch_matches
    render_success(format_response(matches_data))
  end

  private

  def fetch_matches
    FootballApiService.new.get_matches(params[:competition])
  end

  def format_response(matches_data)
    {
      matches: matches_data[:data]['matches'],
      competition: params[:competition]
    }
  end
end
