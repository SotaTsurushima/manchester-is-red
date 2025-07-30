class FetchMatchesWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform
    begin
      Matches::FbrefMatchesService.new.fetch_and_save_matches
      Rails.logger.info 'Successfully fetched and saved matches from Transfermarkt.'
    rescue => e
      Rails.logger.error "Error fetching matches: #{e.message}"
      raise e
    end
  end
end 
