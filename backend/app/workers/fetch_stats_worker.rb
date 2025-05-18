require 'selenium-webdriver'

class FetchStatsWorker
  include Sidekiq::Worker

  def perform
    FetchTransfermarktStatsService.new.call
  end
end
