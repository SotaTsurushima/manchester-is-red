class PlayersController < ApplicationController
  def index
    players = Player.all
    render_success(players.as_json(only: [:id, :name, :number, :position, :image]))
  end
  
  def create
    name = params.require(:name)
    number = params.require(:number)
    position = params.require(:position)
    file = params.require(:file)

    url = Players::PlayerUploader.upload(file)

    player = Player.new(
      name: name,
      number: number,
      position: position,
      image: url
    )

    if player.save
      render_success({
        id: player.id,
        name: player.name,
        number: player.number,
        position: player.position,
        image: player.image,
        url: url
      })
    else
      render json: { success: false, errors: player.errors.full_messages }, status: :unprocessable_entity
    end
  end
end