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
    red_card: 'cards_red',
    mvp: 'player_of_match'
  }.freeze  

  BATCH_SIZE = 5
  BATCH_WAIT_TIME = 30
  
  def fetch_player_stats
    puts "Starting to fetch player stats..."
    rows = fetch_player_rows
    process_rows(rows)
  end

  private

  def fetch_player_rows
    doc = fetch_with_retry(FBREF_URL)
    doc.css('table#stats_standard_9 tbody tr')
  end

  def process_rows(rows)
    puts "Found #{rows.length} players to process"
    rows.each_slice(BATCH_SIZE) do |batch_rows|
      puts "Processing batch of #{batch_rows.length} players"
      process_batch(batch_rows)
      sleep(BATCH_WAIT_TIME)
    end
  end

  def process_batch(rows)
    rows.each { |row| process_player(row) }
  end

  def process_player(row)
    return if row.css('th').empty?

    name = row.css('th a').text.strip
    link = row.css('th a').first['href']
    player = find_player_by_partial_name(name)
    
    return puts "Player not found in database: #{name}" unless player
    return puts "Player #{name} is not updatable" unless player.respond_to?(:update)

    update_player(player, row, link)
  end

  def update_player(player, row, link)
    new_stats = fetch_new_stats(row)
    salary = fetch_player_info(link, 'Wages', '[£￡]')
    
    update_params = new_stats.merge(salary: salary)
    
    if stats_changed?(player, update_params)
      update_player_record(player, update_params)
    else
      puts "No changes detected for player #{player.name}"
    end
  end

  def update_player_record(player, params)
    if player.update(params)
      puts "Successfully updated player #{player.name}"
    else
      puts "Failed to update player #{player.name}: #{player.errors.full_messages.join(', ')}"
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
        normalized_db_name == normalized_fbref_name,
        normalized_db_name.include?(normalized_fbref_name),
        normalized_fbref_name.include?(normalized_db_name),
        normalized_db_name.split.last == normalized_fbref_name.split.last,
        normalized_db_name.split.first == normalized_fbref_name.split.first,
        normalized_db_name.gsub(/\s+/, '') == normalized_fbref_name.gsub(/\s+/, ''),
        normalized_db_name.split.any? { |word| normalized_fbref_name.include?(word) },
        normalized_fbref_name.split.any? { |word| normalized_db_name.include?(word) }
      ]
      
      patterns.any?
    end
  end

  def normalize_name(name)
    return '' unless name
    
    name.downcase
       .gsub(/\s+/, ' ')
       .strip
       .gsub(/[éèêë]/, 'e')
       .gsub(/[áàâä]/, 'a')
       .gsub(/[íìîï]/, 'i')
       .gsub(/[óòôö]/, 'o')
       .gsub(/[úùûü]/, 'u')
       .gsub(/[ýỳŷÿ]/, 'y')
       .gsub(/[ñ]/, 'n')
       .gsub(/[ç]/, 'c')
  end

  def fetch_new_stats(row)
    STATS_MAPPING.transform_values do |stat_key|
      row.css("td[data-stat='#{stat_key}']").text.to_i
    end
  end

  def stats_changed?(player, new_stats)
    new_stats.any? { |key, value| player.send(key) != value }
  end
end