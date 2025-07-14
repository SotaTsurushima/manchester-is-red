class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  private

  def require_admin!
    unless current_user&.role == 'admin'
      render json: { error: '管理者のみ実行できます' }, status: :forbidden
    end
  end
end
