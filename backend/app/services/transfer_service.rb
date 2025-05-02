class TransferService
  include HTTParty
  include ServiceHandler

  SKY_SPORTS_URL = 'https://www.skysports.com'
  ROMANO_URL = 'https://romano.com'  # Romanoの公式サイトURL

  def initialize
    @sky_sports = NewsSources::SkySportsService.new
    @romano = NewsSources::RomanoService.new
  end

  def get_all_transfer_news
    handle_response do
      news = {
        sky_sports: @sky_sports.get_transfer_news,
        romano: @romano.get_transfer_news
      }

      # 必要に応じて、全ニュースを日付順にソートして返すことも可能
      # combine_and_sort_news(news)
      news
    end
  end

  # 後方互換性のために残す
  def get_manchester_united_news
    get_transfer_news
  end

  private

  def handle_response
    yield
  rescue => e
    Rails.logger.error "Failed to fetch transfer news: #{e.message}"
    { sky_sports: [], romano: [] }
  end

  def combine_and_sort_news(news)
    all_news = news[:sky_sports] + news[:romano]
    all_news.sort_by { |item| item[:date] }.reverse
  end

  def parse_news_items(doc)
    doc.css('.sdc-site-tiles__item, article').map do |item|
      title = item.css('h3, .sdc-site-tile__headline').text.strip
      image = item.css('img').first&.[]('data-src') || item.css('img').first&.[]('src')
      
      # タイトルと画像が存在し、かつ移籍関連の記事のみを抽出
      if title.present? && image.present? && is_transfer_news?(title)
        {
          title: title,
          url: build_url(item.css('a').first&.[]('href')),
          image: image,
          date: item.css('time, .sdc-site-tile__date').text.strip.presence || Time.current.strftime('%d %B %Y'),
          description: item.css('p, .sdc-site-tile__sub-headline').text.strip
        }
      end
    end.compact
  end

  def is_transfer_news?(title)
    # 移籍関連のキーワードを含むタイトルのみを抽出
    keywords = [
      'transfer',
      'deal',
      'signs',
      'signing',
      'bid',
      'move',
      'joins',
      'fee',
      'contract',
      'talks',
      'interest',
      'target'
    ]
    
    # タイトルを小文字に変換して、キーワードとマッチするか確認
    title_downcase = title.downcase
    keywords.any? { |keyword| title_downcase.include?(keyword) }
  end

  def build_url(path)
    return nil unless path
    path.start_with?('http') ? path : "#{self.class.base_uri}#{path}"
  end
end
