class Admin::SessionsController < DeviseTokenAuth::SessionsController
  def create
    super do |resource|
      unless resource && resource.role == 'admin'
        # admin以外は強制的に失敗
        render json: { error: '管理者のみログインできます' }, status: :unauthorized and return
      end
    end
  end
end
