class User < ApplicationRecord
  has_secure_password
  
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :role, presence: true, inclusion: { in: %w[admin user] }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  
  scope :admins, -> { where(role: 'admin') }
  scope :users, -> { where(role: 'user') }
  
  def admin?
    role == 'admin'
  end
  
  def user?
    role == 'user'
  end
end
