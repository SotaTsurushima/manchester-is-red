class TransferService
  include HTTParty
  include ServiceHandler
  
  base_uri 'https://www.skysports.com'

  def get_manchester_united_news
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
      
      # titleとimageが両方存在する場合のみハッシュを返す
      if title.present? && image.present?
        {
          title: title,
          url: build_url(item.css('a').first&.[]('href')),
          image: image,
          date: item.css('time, .sdc-site-tile__date').text.strip.presence || Time.current.strftime('%d %B %Y'),
          description: item.css('p, .sdc-site-tile__sub-headline').text.strip
        }
      end
    end.compact  # nilの要素を除去
  end

  def build_url(path)
    return nil unless path
    path.start_with?('http') ? path : "#{self.class.base_uri}#{path}"
  end
end
