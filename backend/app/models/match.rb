class Match < ApplicationRecord
  validates :utc_date, :home_team, :away_team, :competition, presence: true

  scope :finished, -> { where(status: 'FINISHED') }

  belongs_to :home_team, class_name: 'Team'
  belongs_to :away_team, class_name: 'Team'
  
  has_many :match_details, dependent: :destroy
  
  has_many :goals, -> { where.not(scorer_name: nil) }, class_name: 'MatchDetail'
  has_many :assists, -> { where.not(assist_name: nil) }, class_name: 'MatchDetail'
end
