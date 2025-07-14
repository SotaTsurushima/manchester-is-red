Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  get "/matches", to: "matches#index"
  get "/transfers", to: "transfers#index"
  get '/injuries', to: 'injury_players#index'
  post 'upload', to: 'uploads#create'
  resources :players, only: [:index, :create, :show, :update, :destroy]
  resources :matches, only: [:index, :show]
  resources :users, only: [:index, :show]

  namespace :admin do
    mount_devise_token_auth_for 'User', at: 'auth', controllers: {
      sessions: 'admin/sessions'
    }
    post 'batch/matches', to: 'batch#matches'
    post 'batch/players_stats', to: 'batch#players_stats'
    post 'batch/teams', to: 'batch#teams'
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
