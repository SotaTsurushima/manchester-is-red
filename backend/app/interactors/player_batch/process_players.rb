require 'set'
require 'nokogiri'
require 'open-uri'

module PlayerBatch
  class ProcessPlayers
    include Interactor
    include Retry
    
    BATCH_SIZE = 5
    BATCH_WAIT_TIME = 30
    STATS_MAPPING = {
      appearances: 'games',
      goals: 'goals',
      assists: 'assists',
      yellow_card: 'cards_yellow',
      red_card: 'cards_red'
    }.freeze
    
    def call
      context.processed_players = Set.new
      context.updated_count = 0
      
      context.rows.each_slice(BATCH_SIZE) do |batch_rows|
        process_batch(batch_rows)
        sleep(BATCH_WAIT_TIME)
      end
    end
    
    private
    
    def process_batch(rows)
      rows.each { |row| process_player(row) }
    end
    
    def process_player(row)
      return if row.css('th').empty?
      
      name = row.css('th a').text.strip
      normalized_name = normalize_name(name)
      return if context.processed_players.include?(normalized_name)
      
      player = find_player_by_name(name)
      return unless player
      
      link = row.css('th a').first['href']
      if update_player_stats(player, row, link)
        context.updated_count += 1
      end
      
      context.processed_players << normalized_name
    end
    
    def find_player_by_name(fbref_name)
      normalized_fbref_name = normalize_name(fbref_name)
      
      Player.all.find do |player|
        normalized_db_name = normalize_name(player.name)
        
        # 完全一致
        return player if normalized_db_name == normalized_fbref_name
        
        # 部分一致のパターン
        patterns = [
          normalized_db_name.include?(normalized_fbref_name),
          normalized_fbref_name.include?(normalized_db_name),
          normalized_db_name.split.last == normalized_fbref_name.split.last,
          normalized_db_name.split.first == normalized_fbref_name.split.first,
          normalized_db_name.gsub(/\s+/, '') == normalized_fbref_name.gsub(/\s+/, '')
        ]
        
        patterns.any?
      end
    end
    
    def update_player_stats(player, row, link)
      new_stats = fetch_new_stats(row)
      salary = fetch_player_salary(link)
      update_params = new_stats.merge(salary: salary)
      
      if stats_changed?(player, update_params)
        player.update(update_params)
        true
      else
        false
      end
    rescue => e
      Rails.logger.error "プレイヤー #{player.name} の更新に失敗しました: #{e.message}"
      false
    end
    
    def fetch_new_stats(row)
      STATS_MAPPING.transform_values do |stat_key|
        row.css("td[data-stat='#{stat_key}']").text.to_i
      end
    end
    
    def fetch_player_salary(player_url)
      return 0 unless player_url
      
      full_url = "https://fbref.com#{player_url}"
      player_doc = fetch_with_retry(full_url)
      text = player_doc.at_css("div#meta div:contains('Wages')")&.text&.strip
      
      if text && (match = text.match(/[£￡]\s*(\d+\.?\d*)/))
        match[1].to_f.to_i
      else
        0
      end
    end
    
    def stats_changed?(player, new_stats)
      changes = new_stats.select { |key, value| player.send(key).to_i != value.to_i }
      changes.any?
    end
    
    def normalize_name(name)
      NameNormalizer.normalize_name(name)
    end
  end
end