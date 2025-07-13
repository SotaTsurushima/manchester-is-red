class UsersController < ApplicationController
  include ErrorHandler

  def index
    users = User.all
    render json: { success: true, data: users.as_json(except: [:password_digest]) }
  end

  def show
    user = User.find(params[:id])
    render json: { success: true, data: user.as_json(except: [:password_digest]) }
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, error: 'User not found' }, status: :not_found
  end
end
