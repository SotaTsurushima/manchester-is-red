class FetchPlayersWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3  # 失敗時に3回までリトライ

  def perform
    result = PlayerBatch::FetchFbrefData.call
    result.fail!(error: 'FBrefデータの取得に失敗しました') unless result.success?
  end
end
