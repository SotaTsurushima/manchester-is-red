require 'nokogiri'
require 'open-uri'

module PlayerBatch
  class FetchFbrefData
    include Interactor
    include Retry
    
    FBREF_URL = 'https://fbref.com/en/squads/19538871/Manchester-United-Stats'
    
    def call
      context.rows = fetch_player_rows
      
      process_result = ProcessPlayers.call(rows: context.rows)
      
      if process_result.success?
        Rails.logger.info "=== プレイヤー処理完了: #{process_result.updated_count}件更新 ==="
        context.updated_count = process_result.updated_count
      else
        context.fail!(error: "プレイヤー処理に失敗しました: #{process_result.error}")
      end
    rescue => e
      context.fail!(error: "FBrefデータの取得に失敗しました: #{e.message}")
    end
    
    private
    
    def fetch_player_rows
      doc = fetch_with_retry(FBREF_URL)
      doc.css('table#stats_standard_9 tbody tr')
    end
  end
end
