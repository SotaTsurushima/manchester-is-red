class TransfersController < ApplicationController
  def index  
    news = TransferService.new.get_manchester_united_news
    render json: { transfers: news }
  rescue StandardError => e
    Rails.logger.error "Error fetching transfers: #{e.message}"
    render json: { 
      error: "Failed to fetch transfers",
      message: e.message 
    }, status: :unprocessable_entity
  end

  private

  def fetch_news
    TransferService.new.get_news
  end

  def handle_error(error)
    Rails.logger.error "Error fetching news: #{error.message}"
    render json: { 
      error: "Failed to fetch news",
      message: error.message 
    }, status: :unprocessable_entity
  end
end
