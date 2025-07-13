class User < ApplicationRecord
  # devise_token_authの設定
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User
  
  # 既存のバリデーション
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :role, presence: true, inclusion: { in: %w[admin user] }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  
  # 既存のスコープ
  scope :admins, -> { where(role: 'admin') }
  scope :users, -> { where(role: 'user') }
  
  # 既存のメソッド
  def admin?
    role == 'admin'
  end
  
  def user?
    role == 'user'
  end
end
