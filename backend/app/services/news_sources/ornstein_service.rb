require 'rss'
require 'open-uri'
require 'httparty'
require 'json'

module NewsSources
  class OrnsteinService
    GOOGLE_NEWS_RSS_URL = 'https://news.google.com/rss/search?q=David+Ornstein+Manchester+United'

    def get_transfer_news
      articles = []
      URI.open(GOOGLE_NEWS_RSS_URL) do |rss|
        feed = RSS::Parser.parse(rss)
        feed.items.first(10).each do |item|
          # pubDateが2日以内か判定
          next unless item.pubDate && item.pubDate.to_date >= Date.today - 1

          articles << {
            title: item.title,
            url: item.link,
            date: item.pubDate,
            description: item.description,
            image: fetch_wikipedia_image_by_title(item.title),
            source: "Google News",
            reliability: "Tier 2"
          }
        end
      end
      articles
    rescue => e
      Rails.logger.error("Ornstein Google News fetch error: #{e}")
      []
    end

    def fetch_wikipedia_image_by_title(title)
      # 1. タイトルでWikipediaを検索
      search_url = "https://en.wikipedia.org/w/api.php"
      search_params = {
        action: "query",
        list: "search",
        srsearch: title,
        format: "json"
      }
      search_response = HTTParty.get(search_url, query: search_params)
      search_data = JSON.parse(search_response.body)
      first_result = search_data.dig("query", "search")&.first
      return nil unless first_result

      # 2. 最初の検索結果のタイトルで画像を取得
      page_title = first_result["title"]
      image_url = fetch_wikipedia_image(page_title)
      image_url
    end

    def fetch_wikipedia_image(page_title)
      url = "https://en.wikipedia.org/w/api.php"
      params = {
        action: "query",
        titles: page_title,
        prop: "pageimages",
        format: "json",
        pithumbsize: 400
      }
      response = HTTParty.get(url, query: params)
      data = JSON.parse(response.body)
      pages = data.dig("query", "pages")
      return nil unless pages
      page = pages.values.first
      page.dig("thumbnail", "source")
    rescue
      nil
    end
  end
end
