module Matches
  class MatchesService
    COMPETITION_MAP = {
      'PL' => 'Premier League',
      'UEL' => 'Europa Lg',
      'FA' => 'FA Cup',
    }

    def self.get_matches(competition_id, page: 1, per_page: 10)
      db_value = COMPETITION_MAP[competition_id] || competition_id
      Rails.cache.fetch("matches/#{db_value}/page#{page}/per#{per_page}/desc", expires_in: 5.minutes) do
        matches = ::Match
                    .where(competition: db_value)
                    .order(utc_date: :desc)
                    .page(page)
                    .per(per_page)
        {
          matches: matches.as_json,
          competition: db_value,
          page: matches.current_page,
          per_page: matches.limit_value,
          total: matches.total_count,
          total_pages: matches.total_pages,
          next_page: matches.next_page,
          prev_page: matches.prev_page
        }
      end
    end
  end
end