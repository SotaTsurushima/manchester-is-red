class PlayersController < ApplicationController
  def index
    players = Player.all
    render_success(players.as_json(only: [:id, :name, :number, :position, :image]))
  end

  def show
    player = Player.find(params[:id])
    render_success(player.as_json(only: [:id, :name, :number, :position, :image]))
  end
  
  def create
    file = params.require(:file)
    url = Players::PlayerUploader.upload(file)

    player = Player.new(player_params.merge(image: url))
    player.save! # バリデーションエラー時はconcernでハンドリング

    render_success(player.as_json(only: [:id, :name, :number, :position, :image]).merge(url: url))
  end

  def update
    player = Player.find(params[:id])

    url = if params[:file].present?
      Players::PlayerUploader.upload(params[:file])
    else
      player.image
    end

    player.update!(player_params.merge(image: url)) # バリデーションエラー時はconcernでハンドリング

    render_success(player.as_json(only: [:id, :name, :number, :position, :image]))
  end

  def destroy
    player = Player.find(params[:id])
    Players::PlayerUploader.delete(player.image) if player.image.present?
    player.destroy!
    render_success({ id: player.id })
  end

  private

  def player_params
    params.permit(:name, :number, :position)
  end
end