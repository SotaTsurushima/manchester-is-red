class TransferNewsAggregatorService
  def get_all_transfer_news
    [
      get_sky_sports_news,
      get_romano_news
    ].flatten.compact.sort_by { |news| news[:date] }.reverse
  end

  private

  def get_sky_sports_news
    TransferService.new.get_manchester_united_news
  rescue => e
    Rails.logger.error "Failed to fetch Sky Sports news: #{e.message}"
    []
  end

  def get_romano_news
    FabrizioRomanoService.new.get_united_transfer_news
  rescue => e
    Rails.logger.error "Failed to fetch Romano news: #{e.message}"
    []
  end
end