require 'httparty'
require 'json'

module NewsSources
  class GuardianService
    include HTTParty
    base_uri 'https://content.guardianapis.com'

    def get_transfer_news
      params = {
        'api-key' => ENV['GUARDIAN_API_KEY'],
        'page-size' => 10,
        'show-fields' => 'headline,trailText,thumbnail',
        'tag' => 'football/manchester-united'
      }
      response = self.class.get('/search', query: params)
      raise "Failed to fetch news. Status: #{response.code}" unless response.success?

      data = JSON.parse(response.body)
      results = data.dig('response', 'results') || []
      results.map do |item|
        {
          title: item.dig('fields', 'headline') || item['webTitle'],
          url: item['webUrl'],
          date: item['webPublicationDate'],
          description: item.dig('fields', 'trailText'),
          image: item.dig('fields', 'thumbnail'),
          source: 'The Guardian',
          reliability: 'Tier 1'
        }
      end
    rescue => e
      Rails.logger.error("Guardian API fetch error: #{e}")
      []
    end
  end
end
