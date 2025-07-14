class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include ErrorHandler

  private

  def require_admin!
    unless current_user&.role == 'admin'
      redirect_to root_path, alert: '管理者のみアクセスできます'
    end
  end
end
