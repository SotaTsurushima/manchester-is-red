# app/services/fbref_stats_service.rb
require 'nokogiri'
require 'open-uri'

class FbrefStatsService
  FBREF_URL = 'https://fbref.com/en/squads/19538871/Manchester-United-Stats'
  
  STATS_MAPPING = {
    appearances: 'games',
    goals: 'goals',
    assists: 'assists',
    yellow_card: 'cards_yellow',
    red_card: 'cards_red'
  }.freeze
  
  def fetch_player_stats
    fetch_from_fbref
  end

  private

  def fetch_from_fbref
    headers = {
      'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    }

    doc = Nokogiri::HTML(URI.open(FBREF_URL, headers))
    table = doc.css('table#stats_standard_9')
    
    stats = []
    table.each do |t|
      t.css('tbody tr').each do |row|
        next if row.css('th').empty?

        fbref_name = row.css('th a').text.strip
        
        player = find_player_by_partial_name(fbref_name)
        
        if player
          new_stats = fetch_new_stats(row)
          
          if player.update(new_stats.merge(market_value: 0))
            puts "Successfully updated stats for: #{player.name}"
          else
            puts "Failed to update stats for: #{player.name}"
            puts "Errors: #{player.errors.full_messages.join(', ')}"
          end
        else
          puts "Player not found in DB: #{fbref_name}"
        end
      end
    end

    stats
  rescue => e
    Rails.logger.error "Failed to fetch FBref stats: #{e.message}"
    puts "Error: #{e.message}"
    []
  end

  private

  def find_player_by_partial_name(fbref_name)
    # 名前を正規化（スペースを削除し、小文字に変換）
    normalized_fbref_name = fbref_name.downcase.gsub(/\s+/, '')
    
    # データベース内の全プレイヤーを取得
    Player.all.find do |player|
      normalized_db_name = player.name.downcase.gsub(/\s+/, '')
      # 部分一致をチェック
      normalized_db_name.include?(normalized_fbref_name) || 
      normalized_fbref_name.include?(normalized_db_name)
    end
  end

  def fetch_new_stats(row)
    STATS_MAPPING.transform_values do |stat_key|
      row.css("td[data-stat='#{stat_key}']").text.to_i
    end
  end

  def format_current_stats(player)
    STATS_MAPPING.keys.map { |key| "#{key}=#{player.send(key)}" }.join(', ')
  end

  def format_new_stats(stats)
    stats.map { |key, value| "#{key}=#{value}" }.join(', ')
  end
end