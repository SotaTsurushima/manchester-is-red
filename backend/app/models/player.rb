class Player < ApplicationRecord
  validates :name, presence: true
  validates :number, presence: true, numericality: { only_integer: true }
  validates :image, presence: true
end
