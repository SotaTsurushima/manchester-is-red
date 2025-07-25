require 'rails_helper'

RSpec.describe Player, type: :model do
  it "is valid with valid attributes" do
    player = FactoryBot.build(:player)
    expect(player).to be_valid
  end

  it "is not valid without a name" do
    player = FactoryBot.build(:player, name: nil)
    expect(player).not_to be_valid
  end
end