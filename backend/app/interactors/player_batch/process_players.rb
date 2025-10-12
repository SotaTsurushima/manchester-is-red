require 'set'
require 'nokogiri'
require 'open-uri'

module PlayerBatch
  class ProcessPlayers
    include Interactor
    include Retry
    include NameNormalizer
    # include TransfermarktStatsService
    
    BATCH_SIZE = 3
    BATCH_WAIT_TIME = 60
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
      @current_row = row
      
      return if @current_row.css('th').empty?
      
      name = @current_row.css('th a').text.strip
      normalized_name = normalize_name(name)
      return if context.processed_players.include?(normalized_name)
      
      # プレイヤーを探すか作成
      player = find_or_create_player(name)
      return unless player
      
      link = @current_row.css('th a').first['href']
      if update_player_stats?(player, link)
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
    
    def update_player_stats?(player, link)
      new_stats = fetch_new_stats
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
    
    def fetch_new_stats
      STATS_MAPPING.transform_values do |stat_key|
        @current_row.css("td[data-stat='#{stat_key}']").text.to_i
      end
    end
    
    def stats_changed?(player, new_stats)
      changes = new_stats.select { |key, value| player.send(key).to_i != value.to_i }
      changes.any?
    end

    def find_or_create_player(name)
      link = @current_row.css('th a').first['href']
      player_doc = fetch_with_retry("https://fbref.com#{link}")

      # market_values = fetch_market_values(name)
      # puts "market_values: #{market_values}"
      
      # デバッグ情報を出力
      puts "=== プレイヤー作成デバッグ ==="
      puts "Name: #{name}"
      puts "Number: #{extract_player_number}"
      
      # 名前で探す、見つからなければ作成
      player = Player.find_or_create_by(name: name) do |p|
        p.number = number || 0
        p.position = extract_position || "Unknown"
        p.image = extract_image(player_doc) || ""
        p.goals = 0
        p.assists = 0
        p.yellow_card = 0
        p.red_card = 0
        p.appearances = 0
        p.market_value = 0
        p.salary = 0
      end
      
      if player.persisted?
        puts "プレイヤー作成成功: #{player.name}"
      else
        puts "プレイヤー作成失敗: #{player.errors.full_messages}"
      end
      
      player
    rescue => e
      Rails.logger.error "プレイヤー #{name} の作成に失敗しました: #{e.message}"
      puts "エラー: #{e.message}"
      nil
    end

    def fetch_player_basic_info(player_url)
      return { image: nil } unless player_url
      
      full_url = "https://fbref.com#{player_url}"
      player_doc = fetch_with_retry(full_url)

      { image: extract_image(player_doc) }
    rescue => e
      Rails.logger.error "プレイヤー情報の取得に失敗しました: #{e.message}"
      { image: nil }
    end

    def extract_player_number
      number_cell = @current_row.css('td[data-stat="number"]').text.strip
      number_cell.to_i if number_cell.match?(/^\d+$/)
    end

    def extract_position
      position_element = @current_row.at_css('td[data-stat="position"]').text.strip
    end

    def extract_image(doc)
      img_element = doc.at_css("div#meta img")
      img_element&.[]('src')
    end
  end
end
