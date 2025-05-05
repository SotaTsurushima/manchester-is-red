require 'open-uri'
require 'nokogiri'

class InjuryPlayersService
  TRANSFERMARKT_URL = 'https://www.transfermarkt.com/manchester-united/startseite/verein/985'

  def fetch_injuries
    doc = Nokogiri::HTML(URI.open(TRANSFERMARKT_URL))
    player_rows = doc.css('table.items tbody tr[class]')

    injuries = []

    player_rows.each do |row|
      injury_icon = row.at('span.verletzt-table')
      next unless injury_icon

      number = row.at('td.rueckennummer')&.text&.strip

      # 怪我情報（title属性からパース）
      injury_info = injury_icon['title'] # 例: "Cruciate ligament injury - Return expected on Jan 1, 2026"
      if injury_info
        # 怪我の種類と復帰予定日を分割
        injury, return_info = injury_info.split(' - Return expected on ')
        return_date = return_info # "Jan 1, 2026" など

        injuries << {
          number: number,
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