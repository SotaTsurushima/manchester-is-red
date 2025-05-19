# app/workers/fetch_player_stats_worker.rb
class FetchPlayerStatsWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3  # 失敗時に3回までリトライ

  def perform
    stats = FbrefStatsService.new.fetch_player_stats
    if stats.present?
      Player.update_all(stats)
    else
      # エラー通知
      NotificationService.notify_admin("Failed to fetch player stats")
    end
  rescue => e
    Rails.logger.error "Error fetching player stats: #{e.message}"
    raise e  # Sidekiqのリトライ機能を利用
  end
end