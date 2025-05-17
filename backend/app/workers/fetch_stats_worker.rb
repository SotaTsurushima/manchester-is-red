class FetchStatsWorker
  include Sidekiq::Worker

  def perform
    # ここで外部APIやスクレイピングでデータ取得
    # 仮の例
    data = [
      { name: "Marcus Rashford", goals: 10, assists: 5 },
      { name: "Bruno Fernandes", goals: 8, assists: 7 }
    ]

    data.each do |player_data|
      player = Player.find_by(name: player_data[:name])
      next unless player
      player.update(goals: player_data[:goals], assists: player_data[:assists])
    end
  end
end
