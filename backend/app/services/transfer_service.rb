class TransferService
  include HTTParty
  include ServiceHandler

  SOURCES = {
    sky_sports: NewsSources::SkySportsService,
    guardian:   NewsSources::GuardianService,
    ornstein:   NewsSources::OrnsteinService
  }

  def initialize
    @sources = SOURCES.transform_values(&:new)
  end

  def get_all_transfer_news
    handle_response do
      news = @sources.transform_values { |service| wrap_source(service.get_transfer_news) }
      news
    end
  end

  private

  def wrap_source(result)
    return result if result.is_a?(Hash) && result.key?(:success) && result.key?(:data)
    { success: true, data: result }
  end
end
