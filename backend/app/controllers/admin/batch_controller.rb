class Admin::BatchController < Admin::BaseController
  include ErrorHandler

  def matches
    FetchMatchesWorker.new.perform
    render json: { success: true, message: "Matches batch started" }
  end

  def players_stats
    FetchPlayerStatsWorker.new.perform
    render json: { success: true, message: "Players stats batch started" }
  end

  def teams
    FetchTeamsWorker.new.perform
    render json: { success: true, message: "Teams batch started" }
  end
end
