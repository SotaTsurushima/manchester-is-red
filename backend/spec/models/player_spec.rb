require 'rails_helper'

RSpec.describe Player, type: :model do
  it "is valid with valid attributes" do
    player = Player.new(name: "Bruno Fernandes", position: "MF")
    expect(player).to be_valid
  end

  it "is not valid without a name" do
    player = Player.new(position: "MF")
    expect(player).not_to be_valid
  end
end 