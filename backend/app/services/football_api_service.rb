class FootballApiService
  include HTTParty
  base_uri "https://api.football-data.org/v4/teams/66"

  def initialize
    @headers = { "X-Auth-Token" => ENV.fetch("FOOTBALL_API_TOKEN", nil) }
  end

  def fetch_matches
    self.class.get("/matches", headers: @headers)
  end
end
