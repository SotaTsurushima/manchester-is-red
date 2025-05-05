class PlayersController < ApplicationController
  def create
    name = params.require(:name)
    number = params.require(:number)
    file = params.require(:file)

    url = Players::PlayerUploader.upload(file)

    player = Player.new(
      name: name,
      number: number,
      image: url
    )

    if player.save
      render_success({
        id: player.id,
        name: player.name,
        number: player.number,
        image: player.image,
        url: url
      })
    else
      render json: { success: false, errors: player.errors.full_messages }, status: :unprocessable_entity
    end
  end
end