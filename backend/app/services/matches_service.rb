class MatchesService
  def self.get_matches(competition_id)
    Rails.cache.fetch("matches/#{competition_id}", expires_in: 5.minutes) do
      new.fetch_and_format_matches(competition_id)
    end
  end

  def fetch_and_format_matches(competition_id)
    matches_data = fetch_matches(competition_id)
    format_response(matches_data, competition_id)
  end

  private

  def fetch_matches(competition_id)
    FootballApiService.new.get_matches(competition_id)
  end

  def format_response(matches_data, competition_id)
    {
      matches: matches_data[:data]['matches'],
      competition: competition_id
    }
  end
end