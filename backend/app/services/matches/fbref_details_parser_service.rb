module Matches
  class MatchDetailsParser
    def initialize(match, match_doc)
      @match = match
      @doc = match_doc
    end

    def save_details
      save_goals
      save_assists
    end

    private

    def save_goals
      @doc.css('div#div_goals_scored table tbody tr').each do |row|
        player_name = row.at_css('td[data-stat="player"] a')&.text&.strip
        next unless player_name

        @match.match_details.create!(
          scorer_name: player_name,
          additional_data: { event_type: 'goal' }
        )
      end
    end

    def save_assists
      @doc.css('div#div_goals_assisted table tbody tr').each do |row|
        player_name = row.at_css('td[data-stat="player"] a')&.text&.strip
        next unless player_name

        @match.match_details.create!(
          assist_name: player_name,
          additional_data: { event_type: 'assist' }
        )
      end
    end
  end
end