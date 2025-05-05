module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  end

  private

  def handle_error(e)
    Rails.logger.error e.full_message # ログにも詳細を出す
    render json: {
      success: false,
      error: e.message,
      class: e.class.to_s,
      full_message: e.full_message(highlight: false, order: :top)
    }, status: :internal_server_error
  end

  def handle_not_found(e)
    render json: { success: false, error: 'Resource not found' }, status: :not_found
  end

  def handle_parameter_missing(e)
    render json: { success: false, error: e.message }, status: :bad_request
  end

  def render_success(data)
    render json: { success: true, data: data }
  end
end
