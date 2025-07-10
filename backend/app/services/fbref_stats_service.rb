# app/services/fbref_stats_service.rb
require 'nokogiri'
require 'open-uri'
require 'set'
require_relative 'name_normalizer'

class FbrefStatsService
  include ServiceHandler
  include NameNormalizer

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
    red_card: 'cards_red',
    # MVP情報は別途取得が必要なため一時的にコメントアウト
    # mvp: 'player_of_match'
  }.freeze  

  BATCH_SIZE = 5
  BATCH_WAIT_TIME = 30
  
  def fetch_player_stats
    rows = fetch_player_rows
    process_rows(rows)
  end

  def debug_table_structure
    puts "=== Debugging FBRef Table Structure ==="
    doc = fetch_with_retry(FBREF_URL)
    
    # テーブルの存在確認
    table = doc.css('table#stats_standard_9')
    puts "Table found: #{table.any?}"
    
    if table.any?
      # ヘッダー行を確認
      headers = table.css('thead th')
      puts "Headers found: #{headers.count}"
      headers.each_with_index do |header, index|
        stat = header['data-stat']
        text = header.text.strip
        puts "#{index}: #{stat} - '#{text}'"
      end
      
      # 最初の選手行を確認
      first_row = table.css('tbody tr').first
      if first_row
        puts "\nFirst player row:"
        first_row.css('td').each_with_index do |cell, index|
          stat = cell['data-stat']
          text = cell.text.strip
          puts "#{index}: #{stat} - '#{text}'"
        end
      end
    end
    
    puts "=== End Debug ==="
  end

  # 簡単なデバッグ用メソッド
  def debug_mvp_availability
    doc = fetch_with_retry(FBREF_URL)
    puts "Available data-stat attributes for first player:"
    first_row = doc.css('table#stats_standard_9 tbody tr').first
    first_row&.css('td')&.each do |cell|
      stat = cell['data-stat']
      puts "  #{stat}: '#{cell.text.strip}'" if stat
    end
  end

  private

  def fetch_player_rows
    doc = fetch_with_retry(FBREF_URL)
    doc.css('table#stats_standard_9 tbody tr')
  end

  def process_rows(rows)
    updated_players = Set.new
    rows.each_slice(BATCH_SIZE) do |batch_rows|
      process_batch(batch_rows, updated_players)
      sleep(BATCH_WAIT_TIME)
    end
  end

  def process_batch(rows, updated_players)
    rows.each { |row| process_player(row, updated_players) }
  end

  def process_player(row, updated_players)
    return if row.css('th').empty?
    name = row.css('th a').text.strip
    normalized_name = normalize_name(name)
    return if updated_players.include?(normalized_name)
    link = row.css('th a').first['href']
    player = find_player_by_partial_name(name)
    return unless player
    return unless player.respond_to?(:update)
    update_player(player, row, link)
    updated_players << normalized_name
  end

  def update_player(player, row, link)
    new_stats = fetch_new_stats(row)
    salary = fetch_player_info(link, 'Wages', '[£￡]')
    update_params = new_stats.merge(salary: salary)
    if stats_changed?(player, update_params)
      update_player_record(player, update_params)
    end
  end

  def update_player_record(player, params)
    player.update(params)
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

  def fetch_player_info(player_url, selector, currency_pattern)
    return 0 unless player_url

    full_url = "https://fbref.com#{player_url}"
    player_doc = fetch_with_retry(full_url)
    text = player_doc.at_css("div#meta div:contains('#{selector}')")&.text&.strip
    
    if text && (match = text.match(/#{currency_pattern}\s*(\d+\.?\d*)/))
      match[1].to_f.to_i
    else
      0
    end
  end

  def find_player_by_partial_name(fbref_name)
    normalized_fbref_name = normalize_name(fbref_name)
    
    Player.all.find do |player|
      normalized_db_name = normalize_name(player.name)
      
      # 完全一致
      return player if normalized_db_name == normalized_fbref_name
      
      # 部分一致のパターン
      patterns = [
        normalized_db_name.include?(normalized_fbref_name),
        normalized_fbref_name.include?(normalized_db_name),
        # 姓のみの一致
        normalized_db_name.split.last == normalized_fbref_name.split.last,
        # 名のみの一致
        normalized_db_name.split.first == normalized_fbref_name.split.first,
        # スペースを除いた完全一致
        normalized_db_name.gsub(/\s+/, '') == normalized_fbref_name.gsub(/\s+/, '')
      ]
      
      patterns.any?
    end
  end

  def fetch_new_stats(row)
    STATS_MAPPING.transform_values do |stat_key|
      row.css("td[data-stat='#{stat_key}']").text.to_i
    end
  end

  def stats_changed?(player, new_stats)
    changes = new_stats.select { |key, value| player.send(key).to_i != value.to_i }
    changes.any?
  end
end