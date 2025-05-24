class FetchPlayerStatsWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3  # 失敗時に3回までリトライ

  def perform
    stats = FbrefStatsService.new.fetch_player_stats
    market_values = TransfermarktStatsService.new.fetch_market_values
  rescue => e
    Rails.logger.error "Error fetching player stats: #{e.message}"
    raise e  # Sidekiqのリトライ機能を利用
  end
end