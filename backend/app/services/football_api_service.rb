class FootballApiService
  include HTTParty
  base_uri 'https://api.football-data.org/v4/teams/66'

  def initialize
    @headers = { "X-Auth-Token" => "b97dbadb4cbf43d2b11f223017d12731" }
  end

  def fetch_matches
    self.class.get('/matches', headers: @headers)
  end
end
