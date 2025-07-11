class FetchTeamsWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform
    begin
      Teams::FootballOrgTeamsService.new.update_crest_urls
      Rails.logger.info 'Successfully fetched and saved teams from FBref.'
    rescue => e
      Rails.logger.error "Error fetching teams: #{e.message}"
      raise e
    end
  end
end