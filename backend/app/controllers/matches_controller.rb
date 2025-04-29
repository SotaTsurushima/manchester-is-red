class MatchesController < ApplicationController
  def index
    football_api = FootballApiService.new
    response = football_api.fetch_matches

    if response.success?
      render json: response.parsed_response
    else
      render json: { error: 'Failed to fetch matches' }, status: :unprocessable_entity
    end
  end
end
