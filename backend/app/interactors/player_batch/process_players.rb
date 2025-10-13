require 'set'
require 'nokogiri'
require 'open-uri'

module PlayerBatch
  class ProcessPlayers
    include Interactor
    include Retry
    include NameNormalizer
    
    BATCH_SIZE = 3
    BATCH_WAIT_TIME = 60
    STATS_MAPPING = {
      appearances: 'games',
      goals: 'goals',
      assists: 'assists',
      yellow_card: 'cards_yellow',
      red_card: 'cards_red',
      position: 'position'
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
      
      name = @current_row.css('th a').text.strip
      normalized_name = normalize_name(name)
      return if context.processed_players.include?(normalized_name)
      
      player = find_player_by_name(name)
      fetch_docs(name)
      @stats = extract_stats

      puts "player: #{name}"

      if player
        puts "更新"
        update_player(player)
      else
        puts "新規作成"
        create_player(player)
      end
      
      context.updated_count += 1
      context.processed_players << normalized_name
    rescue => e
      puts "❌ プレイヤー #{name} の処理でエラー: #{e.message}"
      Rails.logger.error "Player processing failed for #{name}: #{e.message}"
    end

    def find_player_by_name(fbref_name)
      Player.find_by(name: fbref_name)
    end
    
    def create_player(name)
      Player.create!(
        name: name,
        number: extract_player_number || 0,
        position: @stats[:position] || "Unknown",
        image: extract_image || "",
        goals: @stats[:goals] || 0,
        assists: @stats[:assists] || 0,
        yellow_card: @stats[:yellow_card] || 0,
        red_card: @stats[:red_card] || 0,
        appearances: @stats[:appearances] || 0,
        market_value: extract_market_value || 0,
        salary: extract_player_salary || 0
      )
    end
    
    def update_player(player)
      player.update!(
        number: extract_player_number || player.number,
        position: @stats[:position] || player.position,
        appearances: @stats[:appearances] || player.appearances,
        goals: @stats[:goals] || player.goals,
        assists: @stats[:assists] || player.assists,
        yellow_card: @stats[:yellow_card] || player.yellow_card,
        red_card: @stats[:red_card] || player.red_card,
        market_value: extract_market_value || player.market_value,
        salary: extract_player_salary || player.salary
      )
    end

    def fetch_docs(name)
      link = @current_row.css('th a').first['href']
      @fbref_player_doc = fetch_with_retry("https://fbref.com#{link}")
      @markt_doc = fetch_markt_player_doc(name)
    end

    def fetch_markt_player_doc(player_name)
      search_url = "https://www.transfermarkt.com/schnellsuche/ergebnis/schnellsuche?query=#{URI.encode_www_form_component(player_name)}"
      doc = fetch_with_retry(search_url, 2)
      
      # 検索結果から該当プレイヤーを探す
      player_link = find_player_link(doc, player_name)
      player_doc = fetch_with_retry(player_link, 2)
    end

    def find_player_link(doc, player_name)
      # 検索結果から該当プレイヤーのリンクを探す
      doc.css('table.items tbody tr').each do |row|
        name_cell = row.at_css('td.hauptlink a')
        
        if normalize_name(name_cell.text.strip) == normalize_name(player_name)
          return "https://www.transfermarkt.com#{name_cell['href']}"
        end
      end
      nil
    end

    #
    # Extract Stats
    #
    def extract_stats
      STATS_MAPPING.transform_values do |stat_key|
        if stat_key == 'position'
          # position は文字列なので .to_i しない
          @current_row.css("td[data-stat='#{stat_key}']").text.strip
        else
          # 数値データは .to_i する
          @current_row.css("td[data-stat='#{stat_key}']").text.to_i
        end
      end
    end

    def extract_image
      img_element = @fbref_player_doc.at_css("div#meta img")
      img_element&.[]('src')
    end

    def extract_player_salary
      text = @fbref_player_doc.at_css("div#meta div:contains('Wages')")&.text&.strip
      
      if text && (match = text.match(/[£￡]\s*(\d+\.?\d*)/))
        match[1].to_f.to_i
      else
        0
      end
    end

    def extract_player_number
      shirt_number_element = @markt_doc.at_css('.data-header__shirt-number')
      return nil unless shirt_number_element
      
      number_text = shirt_number_element.text.strip
      number_text.gsub(/[#\s]/, '').strip
    end

    def extract_market_value
      market_value_wrapper = @markt_doc.at_css('.data-header__market-value-wrapper')
      return nil unless market_value_wrapper
      
      # 子要素を順番に処理
      currency_symbol = market_value_wrapper.at_css('.waehrung')&.text&.strip
      unit_symbol = market_value_wrapper.css('.waehrung').last&.text&.strip
      
      # テキストノードから数値を抽出
      text_content = market_value_wrapper.text.strip
      market_value = parse_market_value(text_content)
    end

    def parse_market_value(value_str)
      # 数値部分だけを抽出
      numeric = value_str.gsub(/[^\d\.]/, '').to_f
    
      # すでに大きい値なら桁を調整（例: 60000000 → 60）
      case numeric
      when 1_000_000_000..Float::INFINITY
        (numeric / 1_000_000_000).to_i   # billion → 例: 6_000_000_000 → 6
      when 1_000_000..999_999_999
        (numeric / 1_000_000).to_i       # million → 例: 60_000_000 → 60
      when 1_000..999_999
        (numeric / 1_000).to_i           # thousand → 例: 450_000 → 450
      else
        numeric.to_i                     # そのまま
      end
    end
  end
end
