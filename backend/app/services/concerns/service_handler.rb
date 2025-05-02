module ServiceHandler
  extend ActiveSupport::Concern

  private

  def handle_response
    yield
      .then { |result| { success: true, data: result } }
  rescue => e
    { success: false, error: e.message }
  end
end
