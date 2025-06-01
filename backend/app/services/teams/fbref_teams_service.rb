require 'nokogiri'
require 'open-uri'

module Teams
  class FbrefTeamsService
    HEADERS = {
      'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    }.freeze

    def fetch_premier_league_teams
      url = 'https://fbref.com/en/comps/9/Premier-League-Stats'
      doc = fetch_with_retry(url)
      
      doc.css('table#results2024-202591_overall tbody tr').each do |row|
        squad_td = row.css('td')[0]
        next unless squad_td

        team_name = squad_td.at_css('a')&.text&.strip
        team_url = squad_td.at_css('a')&.attr('href')
        crest_img = squad_td.at_css('img')
        crest_url = crest_img&.attr('src')
        crest_url = "https://fbref.com#{crest_url}" if crest_url&.start_with?('/')

        next unless team_name

        team = Team.find_or_initialize_by(name: team_name)
        
        if crest_url.present?
          minio_url = Teams::TeamUploader.upload_from_url(crest_url, team_name)
          team.crest_url = minio_url
        end
        
        team.save!
      end
    end

    def fetch_with_retry(url, max_retries = 3)
      retries = 0
      begin
        sleep(rand(5..10))
        response = URI.open(url, HEADERS)
        Nokogiri::HTML(response)
      rescue OpenURI::HTTPError => e
        if e.message.include?('429') && retries < max_retries
          retries += 1
          sleep(600 * (2 ** (retries - 1)))
          retry
        else
          raise "Failed to fetch data from #{url}: #{e.message}"
        end
      end
    end
  end
end