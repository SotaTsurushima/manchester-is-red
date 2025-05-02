module NewsSources
  class RomanoService
    include NewsParserConcern
    
    base_uri 'https://www.caughtoffside.com'

    def get_transfer_news
      handle_response do
        response = self.class.get('/author/fabrizio-romano')
        raise "Failed to fetch news. Status: #{response.code}" unless response.success?

        parse_news_items(Nokogiri::HTML(response.body))
      end
    end

    private

    def parse_news_items(doc)
      doc.css('.article-item').map do |item|
        
        binding.pry
        
        title = item.css('.article-title').text.strip
        image = item.css('.article-image img').first&.[]('src')

        
        binding.pry
        
        
        if title.present? && is_united_news?(title)
          {
            title: title,
            url: build_url(item.css('.article-link').first&.[]('href'), self.class.base_uri),
            image: image,
            date: parse_date(item.css('.article-date').text.strip),
            description: item.css('.article-excerpt').text.strip,
            source: 'Fabrizio Romano',
            status: get_transfer_status(title),
            reliability: 'Tier 1'
          }
        end
      end.compact
    end
  end
end 