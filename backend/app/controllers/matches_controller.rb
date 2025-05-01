class MatchesController < ApplicationController
  def index
    competition_id = params[:competition]
    service = FootballApiService.new
    
    begin
      matches_data = service.get_matches(competition_id)
      render json: {
        matches: matches_data['matches'],
        competition: competition_id
      }
    rescue => e
      Rails.logger.error "Error fetching matches: #{e.message}"
    end
  end

  private

  def render_response(response)
    if response.success?
      render json: response.parsed_response
    else
      render json: { error: "Failed to fetch matches" }, status: :unprocessable_entity
    end
  end
end
