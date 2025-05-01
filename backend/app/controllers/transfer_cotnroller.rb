class NewsController < ApplicationController
  def index
    news_data = fetch_news
    render json: { news: news_data }
  rescue StandardError => e
    handle_error(e)
  end

  private

  def fetch_news
    SkySportsService.new.get_news
  end

  def handle_error(error)
    Rails.logger.error "Error fetching news: #{error.message}"
    render json: { 
      error: "Failed to fetch news",
      message: error.message 
    }, status: :unprocessable_entity
  end
end
