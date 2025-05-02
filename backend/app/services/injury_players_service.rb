require 'open-uri'
require 'nokogiri'

class InjuryPlayersService
  TRANSFERMARKT_URL = 'https://www.transfermarkt.com/manchester-united/startseite/verein/985'

  def fetch_injuries
    doc = Nokogiri::HTML(URI.open(TRANSFERMARKT_URL))
    injury_table = doc.at('table.items')
    injuries = []

    if injury_table
      injury_table.css('tbody tr').each do |row|
        player = row.at('td:nth-child(2) a')&.text&.strip
        injury = row.at('td:nth-child(5)')&.text&.strip
        return_date = row.at('td:nth-child(6)')&.text&.strip
        next unless player && injury

        injuries << {
          player: player,
          injury: injury,
          return_date: return_date
        }
      end
    end

    injuries
  rescue => e
    Rails.logger.error "Failed to fetch injuries: #{e.message}"
    []
  end
end 