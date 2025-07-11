# backend/app/controllers/admin/batch_controller.rb
class Admin::BatchController < ApplicationController
  
  binding.pry
  
  include ErrorHandler

  def matches
    FetchMatchesWorker.perform_async
    render json: { success: true, message: "Matches batch started" }
  end

  def players_stats
    FetchPlayerStatsWorker.perform_async
    render json: { success: true, message: "Players stats batch started" }
  end

  def teams
    FetchTeamsWorker.perform_async
    render json: { success: true, message: "Teams batch started" }
  end
end
