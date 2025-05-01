class SkySportsService
  include HTTParty
  base_uri 'https://www.skysports.com/manchester-united'

  def get_news
    response = self.class.get('/')
    
    if response.success?
      parse_news(response.body)
    else
      raise "Failed to fetch news from Sky Sports"
    end
  end

  private

  def parse_news(html)
    doc = Nokogiri::HTML(html)
    news_items = doc.css('.news-list__item')
    
    news_items.map do |item|
      {
        title: item.css('.news-list__headline-link').text.strip,
        url: item.css('.news-list__headline-link').attr('href')&.value,
        image_url: item.css('img').attr('data-src')&.value,
        published_at: item.css('.label__timestamp').text.strip,
        description: item.css('.news-list__snippet').text.strip
      }
    end
  end
end
