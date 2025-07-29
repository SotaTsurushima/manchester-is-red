class MatchDetail < ApplicationRecord
  belongs_to :match
  
  # バリデーション
  validates :scorer_name, presence: true, if: :goal_exists?
  validates :assist_name, presence: true, if: :assist_exists?
  
  # スコープ
  scope :goals, -> { where.not(scorer_name: nil) }
  scope :assists, -> { where.not(assist_name: nil) }
  
  private
  
  def goal_exists?
    scorer_name.present?
  end
  
  def assist_exists?
    assist_name.present?
  end
end
