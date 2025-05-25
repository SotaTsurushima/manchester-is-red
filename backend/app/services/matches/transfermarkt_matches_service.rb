require 'nokogiri'
require 'open-uri'

class TransfermarktMatchesService
  BASE_URL = 'https://www.transfermarkt.com/manchester-united/spielplan/verein/985/saison_id/2024'
  HEADERS = {
    'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
  }.freeze

  def fetch_and_save_matches
    doc = Nokogiri::HTML(URI.open(BASE_URL, HEADERS))
    doc.css('table.items tbody tr').each do |row|
      date = row.at_css('td.zentriert[title]')&.text&.strip
      home_team = row.at_css('td.no-border-rechts a')&.text&.strip
      away_team = row.at_css('td.no-border-links a')&.text&.strip
      score = row.at_css('td.zentriert.ergebnis a')&.text&.strip
      competition = row.at_css('td.hauptlink a')&.text&.strip
      venue = row.at_css('td.verein-venue')&.text&.strip
      status = row.at_css('td.status')&.text&.strip

      next unless date && home_team && away_team

      Match.find_or_initialize_by(
        utc_date: DateTime.parse(date),
        home_team: home_team,
        away_team: away_team,
        competition: competition
      ).tap do |m|
        m.score = score
        m.venue = venue
        m.status = status
        m.save!
      end
    end
  end
end 