class TransfersController < ApplicationController
  include ErrorHandler

  def index
    result = TransferService.new.get_manchester_united_news
    render_success(result)
  end
end
