class Match < ApplicationRecord
  validates :utc_date, :home_team, :away_team, :competition, presence: true

  scope :finished, -> { where(status: 'FINISHED') }

  belongs_to :home_team, class_name: 'Team'
  belongs_to :away_team, class_name: 'Team'
end
