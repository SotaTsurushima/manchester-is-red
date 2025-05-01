class MatchesController < ApplicationController
  def index
    matches_data = fetch_matches
    render json: format_response(matches_data)
  rescue StandardError => e
    handle_error(e)
  end

  private

  def fetch_matches
    FootballApiService.new.get_matches(params[:competition])
  end

  def format_response(matches_data)
    {
      matches: matches_data['matches'],
      competition: params[:competition]
    }
  end

  def handle_error(error)
    Rails.logger.error "Error fetching matches: #{error.message}"
    render json: { 
      error: "Failed to fetch matches",
      message: error.message 
    }, status: :unprocessable_entity
  end
end
