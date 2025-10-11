require 'nokogiri'
require 'open-uri'

module PlayerBatch
  class FetchFbrefData
    include Interactor
    
    FBREF_URL = 'https://fbref.com/en/squads/19538871/Manchester-United-Stats'
    HEADERS = {
      'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
      'Accept-Language' => 'en-US,en;q=0.5',
      'Connection' => 'keep-alive'
    }.freeze
    
    def call
      puts "--------------------------------"
      context.rows = fetch_player_rows
    rescue => e
      context.fail!(error: "FBrefデータの取得に失敗しました: #{e.message}")
    end
    
    private
    
    def fetch_player_rows
      doc = fetch_with_retry(FBREF_URL)
      doc.css('table#stats_standard_9 tbody tr')
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
          sleep(1800 * (2 ** (retries - 1)))
          retry
        else
          raise "データの取得に失敗しました #{url}: #{e.message}"
        end
      end
    end
  end
end