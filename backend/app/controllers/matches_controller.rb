# app/controllers/matches_controller.rb
class MatchesController < ApplicationController
  require 'net/http'
  require 'json'
  
  def index
    url = URI.parse('https://api.football-data.org/v4/teams/66/matches')  # マンチェスター・ユナイテッドのID
    
    request = Net::HTTP::Get.new(url)
    request['X-Auth-Token'] = 'b97dbadb4cbf43d2b11f223017d12731'  # APIキーを指定

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    response = http.request(request)

    if response.code.to_i == 200
      matches_data = JSON.parse(response.body)
      render json: matches_data['matches']
    else
      render json: { error: 'Failed to fetch matches' }, status: :unprocessable_entity
    end
  end
end
