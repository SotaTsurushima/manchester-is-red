module Matches
  class MatchesService
    COMPETITION_MAP = {
      'PL' => 'Premier League',
      'UEL' => 'Europa Lg',
      'FA' => 'FA Cup',
      # ...他も同様
    }

    def self.get_matches(competition_id)
      db_value = COMPETITION_MAP[competition_id] || competition_id
      Rails.cache.fetch("matches/#{db_value}", expires_in: 5.minutes) do
        matches = ::Match.where(competition: db_value).order(utc_date: :asc)
        {
          matches: matches.as_json,
          competition: db_value
        }
      end
    end
  end
end