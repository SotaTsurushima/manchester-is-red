module NewsSources
  class SkySportsService
    include NewsParserConcern
    
    base_uri 'https://www.skysports.com'

    def get_transfer_news
      handle_response do
        response = self.class.get('/manchester-united-news')
        raise "Failed to fetch news. Status: #{response.code}" unless response.success?

        parse_news_items(Nokogiri::HTML(response.body))
      end
    end

    private

    def parse_news_items(doc)
      doc.css('.sdc-site-tiles__item, article').map do |item|
        title = item.css('h3, .sdc-site-tile__headline').text.strip
        image = item.css('img').first&.[]('data-src') || item.css('img').first&.[]('src')
        
        if title.present? && image.present? && is_transfer_news?(title)
          {
            title: title,
            url: build_url(item.css('a').first&.[]('href'), self.class.base_uri),
            image: image,
            date: parse_date(item.css('time, .sdc-site-tile__date').text.strip),
            description: item.css('p, .sdc-site-tile__sub-headline').text.strip,
            source: 'Sky Sports',
            reliability: 'Tier 2'
          }
        end
      end.compact
    end
  end
end 