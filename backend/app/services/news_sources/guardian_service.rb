require 'httparty'
require 'json'

module NewsSources
  class GuardianService
    include HTTParty
    base_uri 'https://content.guardianapis.com'

    def get_transfer_news
      from_date = (Date.today - 14).strftime('%Y-%m-%d') # 2週間前の日付をYYYY-MM-DD形式で
      params = {
        'api-key' => ENV['GUARDIAN_API_KEY'],
        'page-size' => 10,
        'show-fields' => 'headline,trailText,thumbnail',
        'tag' => 'football/manchester-united',
        'q' => 'transfer OR signing OR deal OR contract OR bid OR move',
        'order-by' => 'newest',
        'from-date' => from_date
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
      end.select do |news|
        news[:date] && Date.parse(news[:date]) >= Date.today - 2
      end
    rescue => e
      Rails.logger.error("Guardian API fetch error: #{e}")
      []
    end
  end
end
