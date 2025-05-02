class TransferService
  include HTTParty
  base_uri 'https://www.skysports.com'

  def get_manchester_united_news
    response = self.class.get('/manchester-united-news')
    
    if response.code == 200
      doc = Nokogiri::HTML(response.body)
      
      news_items = doc.css('.news-list__item').map do |item|
        {
          title: item.css('.news-list__headline-link').text.strip,
          url: item.css('.news-list__headline-link').attr('href')&.value,
          image: item.css('img').attr('src')&.value,
          date: item.css('.label__timestamp').text.strip
        }
      end
      
      { success: true, data: news_items }
    else
      { success: false, error: "Failed to fetch news. Status: #{response.code}" }
    end
  rescue => e
    { success: false, error: e.message }
  end

  private

  def parse_news(html)
    doc = Nokogiri::HTML(html)
    
    Rails.logger.info "Found elements: #{doc.css('article, .sdc-site-tiles__item').size}"
    
    articles = doc.css('article, .sdc-site-tiles__item')
    
    articles.map do |article|
      {
        title: extract_title(article),
        url: extract_url(article),
        image_url: extract_image(article),
        published_at: extract_date(article),
        description: extract_description(article)
      }
    end.reject { |article| article[:url].nil? }
  end

  def extract_title(article)
    title = article.css('h3, .sdc-site-tile__headline').text.strip
    Rails.logger.debug "Extracted title: #{title}"
    title
  end

  def extract_url(article)
    link = article.css('a').find { |a| a['href']&.include?('transfer') }&.[]('href')
    return nil unless link
    
    url = link.start_with?('http') ? link : "https://www.skysports.com#{link}"
    Rails.logger.debug "Extracted URL: #{url}"
    url
  end

  def extract_image(article)
    img = article.css('img').find { |i| i['data-src'] || i['src'] }
    return nil unless img
    
    image_url = img['data-src'] || img['src']
    Rails.logger.debug "Extracted image URL: #{image_url}"
    image_url
  end

  def extract_date(article)
    date = article.css('time, .sdc-site-tile__date').text.strip
    Rails.logger.debug "Extracted date: #{date}"
    date.empty? ? Time.current.strftime('%d %B %Y') : date
  end

  def extract_description(article)
    desc = article.css('p, .sdc-site-tile__sub-headline').text.strip
    Rails.logger.debug "Extracted description: #{desc}"
    desc
  end
end
