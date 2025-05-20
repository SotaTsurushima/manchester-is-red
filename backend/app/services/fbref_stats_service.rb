# app/services/fbref_stats_service.rb
require 'nokogiri'
require 'open-uri'

class FbrefStatsService
  include ServiceHandler

  FBREF_URL = 'https://fbref.com/en/squads/19538871/Manchester-United-Stats'
  HEADERS = {
    'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language' => 'en-US,en;q=0.5',
    'Connection' => 'keep-alive'
  }.freeze
  
  STATS_MAPPING = {
    appearances: 'games',
    goals: 'goals',
    assists: 'assists',
    yellow_card: 'cards_yellow',
    red_card: 'cards_red'
  }.freeze  

  BATCH_SIZE = 5
  BATCH_WAIT_TIME = 30
  
  def fetch_player_stats
    handle_response do
      doc = fetch_with_retry(FBREF_URL)
      rows = doc.css('table#stats_standard_9 tbody tr')
      
      rows.each_slice(BATCH_SIZE) do |batch_rows|
        process_batch(batch_rows)
        sleep(BATCH_WAIT_TIME)
      end
    end
  end

  private

  def process_batch(rows)
    rows.each do |row|
      next if row.css('th').empty?

      name = row.css('th a').text.strip
      link = row.css('th a').first['href']
      player = find_player_by_partial_name(name)
      
      if player
        new_stats = fetch_new_stats(row)
        if stats_changed?(player, new_stats)
          market_value = fetch_market_value(link)
          player.update(new_stats.merge(market_value: market_value))
        end
      end
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
        sleep(1800 * (2 ** (retries - 1)))
        retry
      else
        raise "Failed to fetch data from #{url}: #{e.message}"
      end
    end
  end

  def fetch_market_value(player_url)
    return 0 unless player_url

    handle_response do
      full_url = "https://fbref.com#{player_url}"
      player_doc = fetch_with_retry(full_url)
      market_value_text = player_doc.at_css('div#meta div:contains("Market Value")')&.text
      
      if market_value_text && market_value_text =~ /€(\d+\.?\d*)([km])?/
        value = $1.to_f
        value = $2 == 'k' ? value / 1000 : value
        value.to_i
      else
        0
      end
    end
  end

  def find_player_by_partial_name(fbref_name)
    normalized_fbref_name = fbref_name.downcase.gsub(/\s+/, '')
    
    Player.all.find do |player|
      normalized_db_name = player.name.downcase.gsub(/\s+/, '')
      normalized_db_name.include?(normalized_fbref_name) || 
      normalized_fbref_name.include?(normalized_db_name)
    end
  end

  def fetch_new_stats(row)
    STATS_MAPPING.transform_values do |stat_key|
      row.css("td[data-stat='#{stat_key}']").text.to_i
    end
  end

  def stats_changed?(player, new_stats)
    STATS_MAPPING.keys.any? do |stat|
      player.send(stat) != new_stats[stat]
    end
  end
end