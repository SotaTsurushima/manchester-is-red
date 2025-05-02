class InjuryPlayersController < ApplicationController
  def index
    injuries = InjuryPlayersService.new.fetch_injuries
    render json: { success: true, data: injuries }
  end
end 