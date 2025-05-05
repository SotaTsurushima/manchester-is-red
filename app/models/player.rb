class Player < ApplicationRecord
  POSITIONS = %w[FW MF DF GK].freeze

  validates :name, presence: true
  validates :number, presence: true, numericality: { only_integer: true }
  validates :image, presence: true
  validates :position, presence: true, inclusion: { in: POSITIONS }
end