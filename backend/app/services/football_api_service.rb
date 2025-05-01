# app/services/football_api_service.rb
class FootballApiService
  include HTTParty
  base_uri 'https://api.football-data.org/v4'

  def initialize
    api_key = ENV['FOOTBALL_API_KEY']
    if api_key.nil? || api_key.empty?
      Rails.logger.error "FOOTBALL_API_KEY is not set!"
      raise "API key is not configured"
    end

    @headers = { 
      'X-Auth-Token' => api_key,
      'Accept' => 'application/json'
    }
  end

  def get_matches(competition_id = nil)
    competition_codes = {
      'PL' => 'PL',    # Premier League
      'CL' => 'CL',    # Champions League
      'FA' => 'FAC',   # FA Cup - ここを'FAC'に修正
      'EFL' => 'EFL'   # League Cup
    }

    team_id = 66  # Manchester United

    begin
      if competition_id && competition_codes[competition_id]
        # FA Cupの場合は特別な処理
        if competition_id == 'FA'
          # まず大会の全試合を取得
          url = "/competitions/#{competition_codes[competition_id]}/matches"
          response = self.class.get(
            url,
            headers: @headers,
            query: {
              season: current_season,
              status: ['SCHEDULED', 'LIVE', 'IN_PLAY', 'PAUSED', 'FINISHED'].join(',')
            }
          )

          # レスポンスからManchester Unitedの試合のみをフィルタリング
          matches_data = response.parsed_response
          if matches_data['matches']
            matches_data['matches'].select! do |match|
              match['homeTeam']['id'] == team_id || match['awayTeam']['id'] == team_id
            end
          end
          return matches_data
        else
          # 他の大会は従来通りの処理
          url = "/teams/#{team_id}/matches"
          response = self.class.get(
            url,
            headers: @headers,
            query: {
              competitions: competition_codes[competition_id],
              status: ['SCHEDULED', 'LIVE', 'IN_PLAY', 'PAUSED', 'FINISHED'].join(','),
              limit: 100,
              season: current_season
            }
          )
        end
      else
        # 全ての試合を取得
        url = "/teams/#{team_id}/matches"
        response = self.class.get(
          url,
          headers: @headers,
          query: {
            status: ['SCHEDULED', 'LIVE', 'IN_PLAY', 'PAUSED', 'FINISHED'].join(','),
            limit: 100
          }
        )
      end

      Rails.logger.info "API Response Code: #{response.code}"
      handle_response(response)
    rescue => e
      Rails.logger.error "API Request Error: #{e.message}"
      raise e
    end
  end

  private

  def current_season
    current_month = Time.current.month
    current_year = Time.current.year
    current_month >= 7 ? current_year : current_year - 1
  end

  def handle_response(response)
    case response.code
    when 200
      response.parsed_response
    when 429
      Rails.logger.error "API rate limit exceeded"
      raise "API rate limit exceeded"
    else
      Rails.logger.error "API error: #{response.code} - #{response.message}"
      raise "API error: #{response.code} - #{response.message}"
    end
  end
end