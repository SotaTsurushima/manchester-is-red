# app/services/football_api_service.rb
class FootballApiService
  include HTTParty
  include ServiceHandler
  
  base_uri 'https://api.football-data.org/v4'

  TEAM_ID = 66  # Manchester United
  COMPETITION_CODES = {
    'PL' => 'PL',    # Premier League
    'CL' => 'CL'     # Champions League
  }.freeze

  def initialize
    @headers = { 
      'X-Auth-Token' => fetch_api_key,
      'Accept' => 'application/json'
    }
  end

  def get_matches(competition_id = nil)
    handle_response do
      competitions = competition_id ? COMPETITION_CODES[competition_id] : COMPETITION_CODES.values.join(',')
      return { 'matches' => [] } unless competitions

      fetch_matches(competitions)
    end
  end

  private

  def fetch_api_key
    ENV['FOOTBALL_API_KEY'].tap do |key|
      raise "API key is not configured" if key.nil? || key.empty?
    end
  end

  def fetch_matches(competitions)
    response = self.class.get(
      "/teams/#{TEAM_ID}/matches",
      headers: @headers,
      query: build_query(competitions)
    )
    
    raise "API error: #{response.code} - #{response.message}" unless response.success?
    raise "API rate limit exceeded" if response.code == 429

    data = response.parsed_response
    add_scorers_to_matches(data['matches']) if data['matches']
    data
  end

  def build_query(competitions)
    {
      competitions: competitions,
      status: ['SCHEDULED', 'LIVE', 'IN_PLAY', 'PAUSED', 'FINISHED'].join(','),
      limit: 100,
      season: current_season
    }
  end

  def add_scorers_to_matches(matches)
    matches.each do |match|
      next unless match['status'] == 'FINISHED'
      match['goals'] = get_match_scorers(match['id'])
    end
  end

  def get_match_scorers(match_id)
    response = self.class.get("/matches/#{match_id}", headers: @headers)
    return nil unless response.success?

    parse_goals(response.parsed_response['goals'])
  end

  def parse_goals(goals_data)
    return [] unless goals_data

    goals_data.map do |goal|
      {
        minute: goal['minute'],
        scorer: goal['scorer']['name'],
        team: goal['team']['id'] == TEAM_ID ? 'HOME' : 'AWAY'
      }
    end
  end

  def current_season
    current_month = Time.current.month
    current_year = Time.current.year
    current_month >= 7 ? current_year : current_year - 1
  end
end