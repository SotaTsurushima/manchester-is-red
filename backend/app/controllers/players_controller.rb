class PlayersController < ApplicationController
  def create
    name = params.require(:name)
    number = params.require(:number)
    file = params.require(:file)

    url = PlayerUploader.upload(file)

    player = Player.create!(
      name: name,
      number: number,
      image: url
    )

    render_success({ id: player.id, name: player.name, number: player.number, image: player.image, url: url })
  end
end