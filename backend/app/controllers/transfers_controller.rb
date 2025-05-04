class TransfersController < ApplicationController
  def index
    transfer_service = TransferService.new
    @news = transfer_service.get_all_transfer_news
    render json: { success: true, data: @news }
  end
end
