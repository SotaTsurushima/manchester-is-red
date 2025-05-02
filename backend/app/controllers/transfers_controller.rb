class TransfersController < ApplicationController
  include ErrorHandler

  def index
    result = TransferService.new.get_manchester_united_news
    render_success(result)
  end

  private

  def handle_error(error)
    Rails.logger.error "Error fetching news: #{error.message}"
    render json: { 
      error: "Failed to fetch news",
      message: error.message 
    }, status: :unprocessable_entity
  end
end
