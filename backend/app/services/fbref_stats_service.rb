# app/services/fbref_stats_service.rb
require 'nokogiri'
require 'open-uri'

class FbrefStatsService
  FBREF_URL = 'https://fbref.com/en/squads/19538871/Manchester-United-Stats'
  
  def fetch_player_stats
    # キャッシュの有効期間を1週間に設定
    Rails.cache.fetch('fbref_player_stats', expires_in: 1.week) do
      fetch_from_fbref
    end
  end

  private

  def fetch_from_fbref
    headers = {
      'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    }

    doc = Nokogiri::HTML(URI.open(FBREF_URL, headers))
    stats = []

    puts 1234

    doc.css('table#stats_standard_squads_summary_for').each do |table|
      puts table
      table.css('tbody tr').each do |row|
        next if row.css('th').empty?

        stats << {
          name: row.css('th a').text.strip,
          appearances: row.css('td[data-stat="games"]').text.to_i,
          goals: row.css('td[data-stat="goals"]').text.to_i,
          assists: row.css('td[data-stat="assists"]').text.to_i,
          yellow_cards: row.css('td[data-stat="cards_yellow"]').text.to_i,
          red_cards: row.css('td[data-stat="cards_red"]').text.to_i
        }
      end
    end

    puts 5678

    stats
  rescue => e
    Rails.logger.error "Failed to fetch FBref stats: #{e.message}"
    []
  end
end