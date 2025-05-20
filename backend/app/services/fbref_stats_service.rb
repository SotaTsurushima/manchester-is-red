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

  BATCH_SIZE = 5  # 一度に処理するプレイヤー数
  BATCH_WAIT_TIME = 30  # バッチ間の待機時間（秒）
  
  def fetch_player_stats
    handle_response do
      fetch_from_fbref
    end
  end

  private

  def fetch_from_fbref
    doc = fetch_with_retry(FBREF_URL)
    rows = doc.css('table#stats_standard_9 tbody tr')
    
    # バッチ処理の実装
    rows.each_slice(BATCH_SIZE) do |batch_rows|
      process_batch(batch_rows)
      sleep(BATCH_WAIT_TIME)  # バッチ間で待機
    end
  end

  def process_batch(rows)
    rows.each do |row|
      next if row.css('th').empty?

      fbref_name = row.css('th a').text.strip
      player_link = row.css('th a').first['href']
      
      process_player(fbref_name, player_link, row)
    end
  end

  def process_player(fbref_name, player_link, row)
    player = find_player_by_partial_name(fbref_name)
    
    if player
      update_player_stats(player, row, player_link)
    else
      Rails.logger.info "Player not found: #{fbref_name}"
    end
  end

  def update_player_stats(player, row, player_link)
    new_stats = fetch_new_stats(row)
    
    if stats_changed?(player, new_stats)
      market_value = fetch_market_value(player_link)
      update_player(player, new_stats, market_value)
    end
  end

  def update_player(player, new_stats, market_value)
    if player.update(new_stats.merge(market_value: market_value))
      Rails.logger.info "Updated stats for: #{player.name}"
    else
      Rails.logger.error "Failed to update #{player.name}: #{player.errors.full_messages.join(', ')}"
    end
  end

  def fetch_with_retry(url, max_retries = 3)
    retries = 0
    begin
      # リクエスト間隔を5-10秒に増加
      sleep(rand(5..10))
      
      response = URI.open(url, HEADERS)
      Nokogiri::HTML(response)
    rescue OpenURI::HTTPError => e
      if e.message.include?('429') && retries < max_retries
        retries += 1
        # 待機時間をより長く設定（30分、1時間、2時間）
        wait_time = 1800 * (2 ** (retries - 1))
        Rails.logger.warn "Rate limit hit, waiting #{wait_time} seconds... (Attempt #{retries}/#{max_retries})"
        sleep(wait_time)
        retry
      else
        raise "Failed to fetch data from #{url}: #{e.message}"
      end
    end
  end

  def fetch_market_value(player_url)
    return 0 unless player_url

    handle_response do
      # 市場価値の取得をスキップする確率を設定（例：20%）
      return 0 if rand < 0.2

      full_url = "https://fbref.com#{player_url}"
      player_doc = fetch_with_retry(full_url)
      parse_market_value(player_doc)
    end
  end

  def parse_market_value(doc)
    market_value_text = doc.at_css('div#meta div:contains("Market Value")')&.text
    
    if market_value_text && market_value_text =~ /€(\d+\.?\d*)([km])?/
      value = $1.to_f
      value = $2 == 'k' ? value / 1000 : value
      value.to_i
    else
      0
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