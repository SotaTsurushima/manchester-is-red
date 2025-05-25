class Match < ApplicationRecord
  validates :utc_date, :home_team, :away_team, :competition, presence: true

  scope :finished, -> { where(status: 'FINISHED') }
end
