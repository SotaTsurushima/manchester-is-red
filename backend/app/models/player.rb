class Player < ApplicationRecord
  validates :name, presence: true
  validates :number, presence: true, numericality: { only_integer: true }
  validates :image, presence: true
  validates :yellow_card, :red_card, :appearances, numericality: { greater_than_or_equal_to: 0 }
  validates :market_value, numericality: { greater_than_or_equal_to: 0 }
end